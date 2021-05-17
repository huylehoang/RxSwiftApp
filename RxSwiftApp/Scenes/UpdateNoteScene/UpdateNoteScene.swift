import RxSwift
import RxCocoa

final class UpdateNoteScene: BaseViewController {
    private lazy var titleTextField: UITextField = {
        let view = PaddingTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Enter title..."
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.borderStyle = .none
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.textColor = .darkText
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.borderStyle = .none
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
        view.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.5), for: .highlighted)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return view
    }()

    override var hideNavigationBar: Bool {
        return false
    }

    override var hidesBackButton: Bool {
        return false
    }

    override var rightBarButtonItems: [UIBarButtonItem] {
        return [updateButton]
    }

    private let viewModel: UpdateNoteViewModel

    private let disposeBag = DisposeBag()

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
    }
}

private extension UpdateNoteScene {
    func setupView() {
        contentView.backgroundColor = .white
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(detailsTextView)
        contentView.addSubview(deleteButton)
        Constraint.activate(
            titleTextField.height.equalTo(48),
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

        let input = UpdateNoteViewModel.Input(
            viewDidLoad: rx.viewDidLoad.asDriver(),
            noteTitle: titleTextField.rx.text.orEmpty.asDriver(),
            noteDetails: detailsTextView.rx.text.orEmpty.asDriver(),
            updateTrigger: updateButton.rx.tap.asDriver(),
            deleteTrigger: deleteTrigger.asDriverOnErrorJustComplete())

        let output = viewModel.transform(input: input)

        [
            output.title.drive(rx.title),
            output.noteTitle.drive(titleTextField.rx.text),
            output.noteDetails.drive(detailsTextView.rx.text),
            output.updateButtonTitle.drive(updateButton.rx.title),
            output.hideDeleteButton.drive(deleteButton.rx.isHidden),
            output.noteTitleIsEmpty.drive(noteTitleIsEmpty),
            output.noteDetailsIsEmpty.drive(noteDetailsIsEmpty),
            output.showToast.drive(rx.showToast),
            output.onAction.drive(),
            output.embeddedIndicator.drive(rx.showEmbeddedIndicatorView),
            output.errorMessage.drive(rx.showErrorMessage),

        ]
        .forEach { $0.disposed(by: disposeBag) }
    }
}

private extension UpdateNoteScene {
    var noteTitleIsEmpty: Binder<Bool> {
        return Binder(self) { base, isEmpty in
            let borderColor: UIColor = isEmpty ? .systemRed : .lightGray
            base.titleTextField.layer.borderColor = borderColor.cgColor
        }
    }

    var noteDetailsIsEmpty: Binder<Bool> {
        return Binder(self) { base, isEmpty in
            let borderColor: UIColor = isEmpty ? .systemRed : .lightGray
            base.detailsTextView.layer.borderColor = borderColor.cgColor
        }
    }
}
