import UIKit

extension BaseViewController {
    private static var embeddedIndicatorViewContext = 0
    private var embeddedIndicatorView: IndicatorView {
        guard let indicatorView = objc_getAssociatedObject(
                self,
                &Self.embeddedIndicatorViewContext) as? IndicatorView
        else {
            let indicatorView = IndicatorView()
            objc_setAssociatedObject(
                self,
                &Self.embeddedIndicatorViewContext,
                indicatorView,
                .OBJC_ASSOCIATION_RETAIN)
            return indicatorView
        }
        return indicatorView
    }

    func showEmbeddedIndicatorView() {
        let window = UIApplication.shared.getWindow()
        window?.addSubview(embeddedIndicatorView)
        guard let superView = embeddedIndicatorView.superview else { return }
        embeddedIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        Constraint.activate(
            embeddedIndicatorView.leading.equalTo(superView.leading),
            embeddedIndicatorView.trailing.equalTo(superView.trailing),
            embeddedIndicatorView.top.equalTo(superView.top),
            embeddedIndicatorView.bottom.equalTo(superView.bottom))
        embeddedIndicatorView.startAnimating()
    }

    func hideEmbeddedIndicatorView() {
        embeddedIndicatorView.stopAnimating()
        embeddedIndicatorView.removeFromSuperview()
    }
}

extension BaseViewController {
    private static var embeddedIndicatorContext = 0
    private var embeddedIndicator: UIActivityIndicatorView {
        guard let indicator = objc_getAssociatedObject(
                self,
                &Self.embeddedIndicatorContext) as? UIActivityIndicatorView
        else {
            let indicator = UIActivityIndicatorView(style: .large)
            objc_setAssociatedObject(
                self,
                &Self.embeddedIndicatorContext,
                indicator,
                .OBJC_ASSOCIATION_RETAIN)
            return indicator
        }
        return indicator
    }

    func showEmbeddedIndicator() {
        contentView.addSubview(embeddedIndicator)
        contentView.bringSubviewToFront(embeddedIndicator)
        embeddedIndicator.translatesAutoresizingMaskIntoConstraints = false
        Constraint.activate(
            embeddedIndicator.centerX.equalTo(contentView.centerX),
            embeddedIndicator.centerY.equalTo(contentView.centerY))
        embeddedIndicator.startAnimating()
    }

    func hideEmbeddedIndicator() {
        embeddedIndicator.stopAnimating()
        embeddedIndicator.removeFromSuperview()
    }
}

extension BaseViewController {
    private static var embeddedEmptyViewContext = 0
    var embeddedEmptyView: EmptyView {
        guard let emptyView = objc_getAssociatedObject(
                self,
                &Self.embeddedEmptyViewContext) as? EmptyView
        else {
            let emptyView = EmptyView()
            objc_setAssociatedObject(
                self,
                &Self.embeddedEmptyViewContext,
                emptyView,
                .OBJC_ASSOCIATION_RETAIN)
            return emptyView
        }
        return emptyView
    }

    func showEmbeddedEmptyView(message: String, actionTitle: String) {
        contentView.addSubview(embeddedEmptyView)
        contentView.bringSubviewToFront(embeddedEmptyView)
        embeddedEmptyView.translatesAutoresizingMaskIntoConstraints = false
        Constraint.activate(
            embeddedEmptyView.top.equalTo(contentView.top),
            embeddedEmptyView.leading.equalTo(contentView.leading),
            embeddedEmptyView.trailing.equalTo(contentView.trailing),
            embeddedEmptyView.bottom.equalTo(contentView.bottom))
        embeddedEmptyView.rx.message.onNext(message)
        embeddedEmptyView.rx.actionTitle.onNext(actionTitle)
    }

    func hideEmbeddedEmptyView() {
        embeddedEmptyView.rx.message.onNext("")
        embeddedEmptyView.rx.actionTitle.onNext("")
        embeddedEmptyView.removeFromSuperview()
    }
}


