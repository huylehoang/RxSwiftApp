import UIKit

typealias Animator = UIViewControllerAnimatedTransitioning
typealias InteractiveAnimator = UIViewControllerInteractiveTransitioning
typealias PercentDrivenAnimator = UIPercentDrivenInteractiveTransition

final class NavigationTransition: NSObject, UINavigationControllerDelegate {
    private var interactiveDismissAnimator: InteractiveAnimator?

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            guard let base = toVC as? BaseViewController else {
                return nil
            }
            return base.transitionKind?.pushAnimator
        case .pop:
            guard let base = fromVC as? BaseViewController else {
                return nil
            }
            guard let interactiveAnimator = base.interactiveDismissAnimator else {
                return base.transitionKind?.popAnimator
            }
            interactiveDismissAnimator = interactiveAnimator
            if interactiveAnimator is PercentDrivenAnimator {
                return base.transitionKind?.popAnimator
            } else {
                return nil
            }
        default:
            return nil
        }
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismissAnimator
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        interactiveDismissAnimator = nil
    }
}

extension NavigationTransition {
    enum Kind {
        case crossDissolve
        case fadeZoom
        case custom(push: Animator, pop: Animator)
    }
}

private extension NavigationTransition.Kind {
    var pushAnimator: Animator? {
        switch self {
        case .crossDissolve: return CrossDissolveAnimator(operation: .push)
        case .fadeZoom: return FadeZoomPushAnimator()
        case .custom(let push, _): return push
        }
    }

    var popAnimator: Animator? {
        switch self {
        case .crossDissolve: return CrossDissolveAnimator(operation: .pop)
        case .fadeZoom: return FadeZoomPopAnimator()
        case .custom(_, let pop): return pop
        }
    }
}
