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

    /* Usage:
     let observable: Observalbe<Void>
     observable
        .map(AlertBuilder.init)
        .withUnretained(self) (self is viewController that inherit from BaseViewController)
        .flatMap { scene, builder in return scene.showAlert(with: builder) }
        ...
    */
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

    /* Usage:
     let observable: Observalbe<Void>
     observable
        .map { "Notify Title" }
        .withUnretained(self) (self is viewController that inherit from BaseViewController)
        .flatMap { scene, title in return scene.showNotify(with: title) }
        ...
    */
    func showNotify(with title: String, confirmButtonTitle: String = "OK") -> Observable<Void> {
        let buidler = AlertBuilder(
            title: title,
            actions: [.init(title: confirmButtonTitle, style: .default, tag: 0)])
        return showAlert(with: buidler).mapToVoid()
    }
}
