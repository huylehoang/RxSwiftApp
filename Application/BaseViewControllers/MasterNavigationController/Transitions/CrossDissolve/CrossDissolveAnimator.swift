import UIKit

final class CrossDissolveAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let operation: UINavigationController.Operation

    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return operation == .push ? 0.25 : 0.15
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let from = transitionContext.viewController(forKey: .from),
            let to = transitionContext.viewController(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        to.view.translatesAutoresizingMaskIntoConstraints = false
        if operation == .push {
            container.insertSubview(to.view, aboveSubview: from.view)
        } else {
            container.insertSubview(to.view, belowSubview: from.view)
        }
        Constraint.activateGroup(to.view.equalToEdges(of: container))
        UIView.transition(
            from: from.view,
            to: to.view,
            duration: transitionDuration(using: transitionContext),
            options: .transitionCrossDissolve,
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!cancelled)
            })
    }
}
