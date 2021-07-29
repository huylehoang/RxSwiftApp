import UIKit

private let duration: TimeInterval = 0.3

final class NormalPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        container.insertSubview(to.view, aboveSubview: from.view)
        Constraint.activateGroup(to.view.equalToEdges(of: container))
        container.layoutIfNeeded()
        to.view.transform = CGAffineTransform(translationX: to.view.frame.width, y: 0)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                from.view.transform = CGAffineTransform(
                    translationX: -from.view.frame.width * 1/3,
                    y: 0)
                to.view.transform = .identity
            },
            completion: { _ in
                let success = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(success)
            })
    }
}

final class NormalPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        container.insertSubview(to.view, belowSubview: from.view)
        Constraint.activateGroup(to.view.equalToEdges(of: container))
        container.layoutIfNeeded()
        to.view.transform = CGAffineTransform(translationX: -to.view.frame.width * 1/3, y: 0)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                from.view.transform = CGAffineTransform(translationX: from.view.frame.width, y: 0)
                to.view.transform = .identity
            },
            completion: { _ in
                let success = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(success)
            })
    }
}
