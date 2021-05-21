import UIKit

typealias Animator = UIViewControllerAnimatedTransitioning
typealias InteractiveAnimator = UIViewControllerInteractiveTransitioning
typealias PercentDrivenAnimator = UIPercentDrivenInteractiveTransition

final class MasterNavigationController: UINavigationController {
    private var interactiveDismissAnimator: InteractiveAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension MasterNavigationController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            guard
                let base = toVC as? BaseViewController,
                let pushAnimator = base.transition?.pushAnimator
            else { return nil }
            return pushAnimator
        case .pop:
            guard let base = fromVC as? BaseViewController else {
                return nil
            }
            if let interactiveDimissal = base as? InteractiveDimissal {
                interactiveDismissAnimator = interactiveDimissal.interactiveDismissAnimator
                return nil
            } else if
                let percentDrivenDismissal = base as? PercentDrivenDimissal,
                let popAnimator = base.transition?.popAnimator
            {
                interactiveDismissAnimator = percentDrivenDismissal.percentDrivenDismissAnimator
                return popAnimator
            } else {
                return base.transition?.popAnimator
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

extension MasterNavigationController {
    enum Transition {
        /*
         - 'normal' transition's animation is nearly the same as default transition's animation
         of navigation controller.
         - The reason for implementing this custom transition (copied from the default) is after we
         triggered any custom transitions'animation, then we use default transition animation
         (leave the variable transition in "BaseViewController" to nil) for other view controller,
         it will cause the "from view controller" disappears from view hierarchy.
         - This replacement will solve this issue (by not using the default transition's animation)
         */
        case normal
        case crossDissolve
        case fadeZoom
        case custom(push: Animator, pop: Animator)
    }
}

private extension MasterNavigationController.Transition {
    var pushAnimator: Animator? {
        switch self {
        case .normal: return NormalPushAnimator()
        case .crossDissolve: return CrossDissolveAnimator(operation: .push)
        case .fadeZoom: return FadeZoomPushAnimator()
        case .custom(let push, _): return push
        }
    }

    var popAnimator: Animator? {
        switch self {
        case .normal: return NormalPopAnimator()
        case .crossDissolve: return CrossDissolveAnimator(operation: .pop)
        case .fadeZoom: return FadeZoomPopAnimator()
        case .custom(_, let pop): return pop
        }
    }
}
