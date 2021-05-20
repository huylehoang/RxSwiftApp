import UIKit

private let duration = 0.25
private let scaleTransfrom = CGAffineTransform(scaleX: 0.3, y: 0.3)

final class FadeZoomPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from),
            let to = transitionContext.viewController(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        to.view.translatesAutoresizingMaskIntoConstraints = false
        to.view.applyMediumShadow()
        container.insertSubview(to.view, aboveSubview: from.view)
        Constraint.activateGroup(to.view.equalToEdges(of: container))
        to.view.transform = scaleTransfrom
        to.view.alpha = 0
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                to.view.transform = .identity
                to.view.alpha = 1
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}

final class FadeZoomPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from),
            let to = transitionContext.viewController(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        from.view.applyMediumShadow()
        to.view.translatesAutoresizingMaskIntoConstraints = false
        container.insertSubview(to.view, belowSubview: from.view)
        Constraint.activateGroup(to.view.equalToEdges(of: container))
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseIn,
            animations: {
                from.view.transform = scaleTransfrom
                from.view.alpha = 0
            },
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!cancelled)
            })
    }
}
