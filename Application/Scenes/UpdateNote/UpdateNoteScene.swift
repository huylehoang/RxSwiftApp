import RxSwift
import RxCocoa

final class UpdateNoteScene: BaseViewController {
    private lazy var titleTextField: LimitCharactersTextField = {
        let view = LimitCharactersTextField(limit: 50)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Enter title..."
        return view
    }()

    private lazy var detailsTextView: UITextView = {
        let view = PlaceholderTextView()
        view.placeholder = "Enter details..."
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var updateButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Delete", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.setTitleColor(.systemBlue.withAlphaComponent(0.5), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return view
    }()

    override var transition: MasterNavigationController.Transition {
        switch viewModel.kind {
        case .add: return .fadeZoom
        case .edit: return .normal
        }
    }

    private var percentDrivenController: PercentDrivenController?

    private let viewModel: UpdateNoteViewModel

    init(viewModel: UpdateNoteViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    deinit {
        dump("Deinit UpdateNoteScene")
    }

    override func loadView() {
        super.loadView()
        setupView()
        setupBinding()
        setupInteractionController()
    }
}

// MARK: - PercentDrivenDimissal
extension UpdateNoteScene: PercentDrivenDimissal {
    var percentDrivenDismissAnimator: PercentDrivenAnimator? {
        return percentDrivenController?.percentDriven
    }
}

private extension UpdateNoteScene {
    func setupView() {
        navigationBarUpdate {
            $0.hidesBackButton = false
            $0.rightBarButtonItems = [updateButton]
        }
        
        contentView.backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(detailsTextView)
        contentView.addSubview(deleteButton)
        Constraint.activate(
            titleTextField.height.equalTo(64),
            stackView.top.equalTo(contentView.safeAreaLayoutGuide.top).constant(12),
            stackView.leading.equalTo(contentView.leading).constant(12),
            stackView.trailing.equalTo(contentView.trailing).constant(-12),
            stackView.bottom.equalTo(deleteButton.top).constant(-12),
            deleteButton.trailing.equalTo(stackView.trailing),
            deleteButton.bottom.equalTo(contentView.safeAreaLayoutGuide.bottom).constant(-12))
    }

    func setupBinding() {
        let deleteTrigger = deleteButton.rx.tap
            .map { AlertBuilder(
                title: "Delete Note",
                message: "Are your sure you want to delete this note?",
                actions: [
                    .init(title: "Cancel", style: .destructive, tag: 0),
                    .init(title: "Confirm", style: .default, tag: 1),
                ])
            }
            .withUnretained(self)
            .flatMap { $0.showAlert(with: $1) }
            .filter { $0 == 1 }
            .mapToVoid()

        let endEditing = Driver.merge(
            titleTextField.rx.endEditing.asDriver(),
            detailsTextView.rx.didEndEditing.asDriver())

        let input = UpdateNoteViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            noteTitle: titleTextField.rx.text.asDriver(),
            noteDetails: detailsTextView.rx.text.orEmpty.asDriver(),
            endEditing: endEditing,
            updateTrigger: updateButton.rx.tap.asDriver(),
            deleteTrigger: deleteTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)

        [
            output.title.drive(rx.title),
            output.noteTitle.drive(titleTextField.rx.text),
            output.noteDetails.drive(detailsTextView.rx.text),
            output.updateButtonTitle.drive(updateButton.rx.title),
            output.hideDeleteButton.drive(deleteButton.rx.isHidden),
            output.noteTitleIsEmpty.drive(setFieldIsEmpty(field: titleTextField)),
            output.noteDetailsIsEmpty.drive(setFieldIsEmpty(field: detailsTextView)),
            output.showToast.drive(rx.showToast),
            output.onAction.drive(),
            output.embeddedIndicator.drive(rx.showEmbeddedIndicatorView),
            output.errorMessage.drive(rx.showErrorMessage),
        ]
        .forEach { $0.disposed(by: disposeBag) }
    }

    func setupInteractionController() {
        switch viewModel.kind {
        case .add:
            percentDrivenController = FadeZoomPercentDrivenController(
                interactiveViewController: self)
        case .edit:
            percentDrivenController = NormalPercentDrivenController(interactiveViewController: self)
        }
    }
}

private extension UpdateNoteScene {
    func setFieldIsEmpty(field: UIView) -> Binder<Bool> {
        return Binder(self) { _, isEmpty in
            let borderColor: UIColor = isEmpty ? .systemRed : .lightGray
            field.layer.borderColor = borderColor.cgColor
        }
    }
}
