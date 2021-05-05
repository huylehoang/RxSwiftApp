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

    func showEmbeddedIndicator() {
        contentView.addSubview(embeddedIndicatorView)
        embeddedIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            embeddedIndicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            embeddedIndicatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            embeddedIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            embeddedIndicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        embeddedIndicatorView.startAnimating()
    }

    func hideEmbeddedIndicator() {
        embeddedIndicatorView.stopAnimating()
        embeddedIndicatorView.removeFromSuperview()
    }
}
