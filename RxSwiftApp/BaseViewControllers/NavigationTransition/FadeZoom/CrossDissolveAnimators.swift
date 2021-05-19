import UIKit

class CrossDissolveAnimator: NSObject, Animator {
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
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        fromView.translatesAutoresizingMaskIntoConstraints = false
        toView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(fromView)
        container.addSubview(toView)
        Constraint.activateGroup(
            fromView.equalToEdges(of: container),
            toView.equalToEdges(of: container))
        UIView.transition(
            from: fromView,
            to: toView,
            duration: transitionDuration(using: transitionContext),
            options: .transitionCrossDissolve,
            completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}
