import RxSwift
import RxCocoa

extension Reactive where Base: BaseViewController {
    var showEmbeddedIndicator: Binder<Bool> {
        return Binder(base) { baseViewController, show in
            if show {
                baseViewController.showEmbeddedIndicator()
            } else {
                baseViewController.hideEmbeddedIndicator()
            }
        }
    }
}

extension Reactive where Base: BaseViewController {
    var showErrorMessage: Binder<String> {
        return Binder(base) { _, message in
            showErrorAlert(message: message)
        }
    }

    private func showErrorAlert(message: String) {
        let topViewController = UIApplication.shared.topViewController ?? base
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topViewController.present(alert, animated: true)
    }
}
