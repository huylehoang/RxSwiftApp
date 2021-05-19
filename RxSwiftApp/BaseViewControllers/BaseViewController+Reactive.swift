import RxSwift
import RxCocoa

extension Reactive where Base: BaseViewController {
    var showEmbeddedIndicatorView: Binder<Bool> {
        return Binder(base) { base, show in
            if show {
                base.showEmbeddedIndicatorView()
            } else {
                base.hideEmbeddedIndicatorView()
            }
        }
    }
}

extension Reactive where Base: BaseViewController {
    var showEmbeddedIndicator: Binder<Bool> {
        return Binder(base) { base, show in
            if show {
                base.showEmbeddedIndicator()
            } else {
                base.hideEmbeddedIndicator()
            }
        }
    }
}

extension Reactive where Base: BaseViewController {
    func showEmbeddedEmptyView(actionTitle: String = "") -> Binder<String> {
        return Binder(base) { base, message in
            if !message.isEmpty {
                base.showEmbeddedEmptyView(message: message, actionTitle: actionTitle)
            } else {
                base.hideEmbeddedEmptyView()
            }
            
        }
    }

    var emptyViewAction: ControlEvent<Void> {
        return base.embeddedEmptyView.rx.action
    }
}

extension Reactive where Base: BaseViewController {
    var showErrorMessage: Binder<String> {
        return Binder(base) { base, message in
            let topViewController = UIApplication.shared.getTopViewController() ?? base
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            topViewController.present(alert, animated: true)
        }
    }
}

extension Reactive where Base: BaseViewController {
    var forceEndEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.view.endEditing(true)
        }
    }
}

extension Reactive where Base: BaseViewController {
    var showToast: Binder<String> {
        return Binder(base) { _, message in
            guard !message.isEmpty else { return }
            Toast.show(message: message)
        }
    }

    func showToat(with duration: TimeInterval) -> Binder<String> {
        return Binder(base) { _, message in
            guard !message.isEmpty else { return }
            Toast.show(message: message, duration: duration)
        }
    }
}
