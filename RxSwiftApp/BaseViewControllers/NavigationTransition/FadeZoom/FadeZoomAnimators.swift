import UIKit

class FadeZoomAnimator: NSObject, Animator {
    fileprivate static let scaleTransfrom = CGAffineTransform(scaleX: 0.3, y: 0.3)

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Override
    }
}

final class FadeZoomPushAnimator: FadeZoomAnimator {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        fromView.translatesAutoresizingMaskIntoConstraints = false
        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.applyMediumShadow()
        container.addSubview(fromView)
        container.addSubview(toView)
        Constraint.activateGroup(
            toView.equalToEdges(of: container),
            fromView.equalToEdges(of: container))
        toView.transform = Self.scaleTransfrom
        toView.alpha = 0
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                toView.transform = .identity
                toView.alpha = 1
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}

final class FadeZoomPopAnimator: FadeZoomAnimator {
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else { return }
        let container = transitionContext.containerView
        fromView.translatesAutoresizingMaskIntoConstraints = false
        fromView.applyMediumShadow()
        toView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(toView)
        container.addSubview(fromView)
        Constraint.activateGroup(
            toView.equalToEdges(of: container),
            fromView.equalToEdges(of: container))
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseIn,
            animations: {
                fromView.transform = Self.scaleTransfrom
                fromView.alpha = 0
            },
            completion: { _ in
                let cancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!cancelled)
            })
    }
}

final class FadeZoomInteractionController {
    private weak var interactiveController: BaseViewController?

    private(set) var percentDriven: UIPercentDrivenInteractiveTransition?

    init(interactiveController: BaseViewController) {
        self.interactiveController = interactiveController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        interactiveController.contentView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let interactiveView = sender.view else { return }
        let interactiveViewWidth = interactiveView.frame.size.width
        let translationX = sender.translation(in: interactiveView).x
        let percentX = abs(translationX) / interactiveViewWidth
        let interactiveViewHeight = interactiveView.frame.size.height
        let translationY = sender.translation(in: interactiveView).y
        let percentY = abs(translationY) / interactiveViewHeight
        let percent = max(percentX, percentY)
        switch sender.state {
        case .began:
            percentDriven = UIPercentDrivenInteractiveTransition()
            interactiveController?.navigationController?.popViewController(animated: true)
            percentDriven?.update(percent)
        case .changed:
            percentDriven?.update(percent)
        default:
            percentDriven?.completionSpeed = 0.5
            if percent > 0.3 {
                percentDriven?.finish()
            } else {
                percentDriven?.cancel()
            }
            percentDriven = nil
        }
    }
}
