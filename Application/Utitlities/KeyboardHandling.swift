import RxSwift

protocol KeyboardHandling: UIViewController {
    var supportViewTypes: [UIView.Type] { get }
    var tapAnywhereToDimissKeyboard: Bool { get }
}

extension KeyboardHandling {
    fileprivate var keyboardManager: KeyboardManager {
        guard let keyboardManager = objc_getAssociatedObject(
                self,
                &KeyboardManager.context) as? KeyboardManager
        else {
            let keyboardManager = KeyboardManager(
                contentView: view,
                supportViewTypes: supportViewTypes,
                tapAnywhereToDimissKeyboard: tapAnywhereToDimissKeyboard)
            objc_setAssociatedObject(
                self,
                &KeyboardManager.context,
                keyboardManager,
                .OBJC_ASSOCIATION_RETAIN)
            return keyboardManager
        }
        return keyboardManager
    }

    var supportViewTypes: [UIView.Type] {
      return [UITextField.self, UITextView.self]
    }

    var tapAnywhereToDimissKeyboard: Bool {
        return true
    }
}

extension Reactive where Base: KeyboardHandling {
    var setupKeyboardHandling: Binder<Void> {
        return Binder(base) { base, _ in
            base.keyboardManager.setup()
        }
    }
}

private final class KeyboardManager: NSObject {
    static var context = 0

    private let disposeBag = DisposeBag()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    private weak var contentView: UIView?
    private let supportViewTypes: [UIView.Type]
    private let tapAnywhereToDimissKeyboard: Bool

    init(
        contentView: UIView,
        supportViewTypes: [UIView.Type],
        tapAnywhereToDimissKeyboard: Bool
    ) {
        self.contentView = contentView
        self.supportViewTypes = supportViewTypes
        self.tapAnywhereToDimissKeyboard = tapAnywhereToDimissKeyboard
    }

    fileprivate func setup() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .withUnretained(self)
            .bind { view, _ in view.addObservingKeyboard() }
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .withUnretained(self)
            .bind { view, _ in view.removeObservingKeyboard() }
            .disposed(by: disposeBag)
    }

    private func addObservingKeyboard() {
        guard tapAnywhereToDimissKeyboard else { return }
        contentView?.window?.addGestureRecognizer(tapGesture)
    }

    private func removeObservingKeyboard() {
        guard tapAnywhereToDimissKeyboard else { return }
        contentView?.window?.removeGestureRecognizer(tapGesture)
    }

    @objc private func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        guard tapGesture.state == .ended else { return }
        UIResponder.currentFirstResponder?.resignFirstResponder()
    }
}

extension KeyboardManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard
            let focusView = UIResponder.currentFirstResponder as? UIView,
            nil != supportViewTypes.firstIndex(where: { focusView.isKind(of: $0) }),
            let touchView = touch.view,
            nil == supportViewTypes.firstIndex(where: { touchView.isKind(of: $0) })
        else { return false }
        return true
    }
}

private extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder?
    static var currentFirstResponder: UIResponder? {
        Self._currentFirstResponder = nil
        UIApplication.shared.sendAction(
            #selector(findFirstResponder(sender:)),
            to: nil,
            from: nil,
            for: nil)
        return Self._currentFirstResponder
    }

    @objc func findFirstResponder(sender: AnyObject) {
        Self._currentFirstResponder = self
    }
}
