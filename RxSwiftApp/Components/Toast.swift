import UIKit

enum Toast {
    static var configuration = Configuration()

    private static var queues = [ToastView]()

    /// Show new ToastView and hide previous
    /// - Parameters:
    /// - `parameters`: message, action callback when tapped on action button
    /// - `viewController`: view controller to show, pass nil will show in the windows.
    /// - `duration`: duration in seconds
    static func show(
        message: String,
        in viewController: UIViewController? = nil,
        duration: TimeInterval? = nil
    ) {
        if !queues.isEmpty {
            queues.first?.removeSnackBarFromSuperview()
            queues.removeFirst()
        }

        let toastView = ToastView(
            message: message,
            viewController: viewController,
            duration: duration ?? Self.configuration.duration)

        toastView.hideCompleted = {
            if Thread.isMainThread {
                queues.removeFirst()
            } else {
                DispatchQueue.global(qos: .default).async {
                    queues.removeFirst()
                }
            }
        }

        queues.append(toastView)
        toastView.scheduleShow()
    }
}

// MARK: Toat Configuration
extension Toast {
    struct Configuration {
        let textFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
        let textColor: UIColor = .white
        let backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7)
        let horizontalPadding: CGFloat = 24
        let duration: TimeInterval = 1 // seconds
        let bottomSpace: CGFloat = 20
    }
}

private class ToastView: UIView {
    private let message: String
    private weak var viewController: UIViewController?
    private let duration: TimeInterval

    private var timer: Timer?
    private var showAnimator: UIViewPropertyAnimator?
    private var hideAnimator: UIViewPropertyAnimator?

    private let minimumFontScale: CGFloat = 0.5
    private let animationDuration: TimeInterval = 0.3

    var hideCompleted: (() -> Void)?

    fileprivate init(
        message: String,
        viewController: UIViewController?,
        duration: TimeInterval
    ) {
        self.message = message
        self.viewController = viewController
        self.duration = duration
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ToastView {
    var container: UIView? {
        return viewController?.view ?? UIApplication.shared.getWindow()
    }

    var configuration: Toast.Configuration {
        return Toast.configuration
    }

    var bottomSpace: CGFloat {
        return configuration.bottomSpace
            + (UIApplication.shared.getWindow()?.safeAreaInsets.bottom ?? 0)
    }

    func setup() {
        guard let container = container else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(message, for: .normal)
        button.setTitleColor(configuration.textColor, for: .normal)
        button.titleLabel?.font = configuration.textFont
        button.titleLabel?.minimumScaleFactor = minimumFontScale
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 24, left: 12, bottom: 24, right: 12)
        button.addTarget(self, action: #selector(actionDidTap(_:)), for: .touchUpInside)
        addSubview(button)
        container.addSubview(self)
        backgroundColor = configuration.backgroundColor
        let horizontalPadding = configuration.horizontalPadding
        Constraint.activate(
            button.leading.equalTo(leading),
            button.trailing.equalTo(trailing),
            button.top.equalTo(top),
            button.bottom.equalTo(bottom),
            leading.equalTo(container.leading).constant(horizontalPadding),
            trailing.equalTo(container.trailing).constant(-horizontalPadding),
            bottom.equalTo(container.bottom).constant(-bottomSpace))
        // Force container layout to get actual ToastView frame height
        container.layoutIfNeeded()
        layer.cornerRadius = frame.height / 2
    }

    @objc func actionDidTap(_ sender: UIButton) {
        hide()
    }

    func scheduleShow() {
        guard let _ = container else { return }
        setup()
        let hideTransform = CGAffineTransform(translationX: 0, y: bottomSpace + frame.height)
        transform = hideTransform
        showAnimator?.stopAnimation(true)
        showAnimator = UIViewPropertyAnimator(
            duration: animationDuration,
            dampingRatio: 0.6,
            animations: { [weak self] in
                self?.transform = .identity
            })
        showAnimator?.addCompletion({ [weak self] _ in
            self?.scheduleHide()
        })
        showAnimator?.startAnimation()
    }

    func scheduleHide() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: duration,
            repeats: false,
            block: { [weak self] _ in
                self?.hide()
            })
    }

    func hide() {
        let hideTransform = CGAffineTransform(translationX: 0, y: bottomSpace + frame.height)
        hideAnimator?.stopAnimation(true)
        hideAnimator = UIViewPropertyAnimator(
            duration: animationDuration,
            dampingRatio: 1.0,
            animations: { [weak self] in
                self?.transform = hideTransform
            })
        hideAnimator?.addCompletion({ [weak self] _ in
            self?.hideCompleted?()
            self?.removeFromSuperview()
        })
        hideAnimator?.startAnimation()
    }

    func removeSnackBarFromSuperview() {
        showAnimator?.stopAnimation(true)
        hideAnimator?.stopAnimation(true)
        removeFromSuperview()
    }
}
