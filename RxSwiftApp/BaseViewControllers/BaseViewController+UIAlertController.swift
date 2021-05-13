import RxSwift

extension BaseViewController {
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        let tag: Int
    }

    struct AlertBuilder {
        let title: String?
        let message: String?
        let style: UIAlertController.Style
        let actions: [AlertAction]

        init(
            title: String? = nil,
            message: String? = nil,
            style: UIAlertController.Style = .alert,
            actions: [AlertAction]
        ) {
            self.title = title
            self.message = message
            self.style = style
            self.actions = actions
        }
    }

    // Use Observable+Extension: flatMap(weak:) for preseting UIAlertController reactive way
    func showAlert(with builder: AlertBuilder) -> Observable<Int> {
        return .create {  observer in
            let alert = UIAlertController(
                title: builder.title,
                message: builder.message,
                preferredStyle: builder.style)
            builder.actions
                .map { action in
                    return UIAlertAction(title: action.title, style: action.style) { _ in
                        observer.onNext(action.tag)
                        observer.onCompleted()
                    }
                }
                .forEach(alert.addAction)
            self.present(alert, animated: true)
            return Disposables.create {
                alert.dismiss(animated: true)
            }
        }
    }

    func showNotify(with title: String, confirmButtonTitle: String = "OK") -> Observable<Void> {
        let buidler = AlertBuilder(
            title: title,
            actions: [.init(title: confirmButtonTitle, style: .default, tag: 0)])
        return showAlert(with: buidler).mapToVoid()
    }
}
