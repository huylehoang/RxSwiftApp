import UIKit

public final class SideMenuScene: BaseViewController {
    struct Confirguration {
        let presentDuration: TimeInterval = 0.25
        let dismissDuration: TimeInterval = 0.25
        let rightOffset: CGFloat = UIScreen.main.bounds.width * 1/5
        let dimmingColor: UIColor = UIColor(red: 33/255, green: 43/255, blue: 54/255, alpha: 0.76)
    }

    static var configuration = Confirguration()

    private weak var embeddedScene: UIViewController?
    private var interactionController: InteractionController?

    public init(embeddedScene: UIViewController) {
        super.init()
        self.embeddedScene = embeddedScene
        setupEmbeddedView()
        setupInteractionController()
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
}

private extension SideMenuScene {
    func setupEmbeddedView() {
        guard let embeddedScene = embeddedScene else { return }
        addChild(embeddedScene)
        contentView.addSubview(embeddedScene.view)
        embeddedScene.didMove(toParent: self)
        embeddedScene.view.translatesAutoresizingMaskIntoConstraints = false
        Constraint.activateGroup(embeddedScene.view.equalToEdges(of: contentView))
    }

    func setupInteractionController() {
        interactionController = InteractionController(interactiveController: self)
    }
}

extension SideMenuScene: UIViewControllerTransitioningDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let presentationController = PresentationController(
            presentedViewController: presented,
            presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimation()
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return DimissingAnimation()
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactionController?.percentController
    }
}

extension SideMenuScene: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }

    public func presentationController(
        _ controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
    ) -> UIViewController? {
        return self
    }
}

private final class PresentingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return SideMenuScene.configuration.presentDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let to = transitionContext.viewController(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        to.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(to.view)
        let rightOffset = SideMenuScene.configuration.rightOffset
        Constraint.activate(
            to.view.leading.equalTo(containerView.leading),
            to.view.top.equalTo(containerView.top),
            to.view.bottom.equalTo(containerView.bottom),
            to.view.trailing.equalTo(containerView.trailing).constant(-rightOffset))
        containerView.layoutIfNeeded()
        to.view.transform = CGAffineTransform(translationX: -to.view.frame.width, y: 0)
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                to.view.transform = .identity
            },
            completion: { _ in
                let success = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(success)
            })
    }
}

private final class DimissingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return SideMenuScene.configuration.dismissDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from) else { return }
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                from.view.transform = CGAffineTransform(translationX: -from.view.frame.width, y: 0)
            },
            completion: { _ in
                let success = !transitionContext.transitionWasCancelled
                transitionContext.completeTransition(success)
            })
    }
}

private final class PresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SideMenuScene.configuration.dimmingColor
        view.alpha = 0.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    override func presentationTransitionWillBegin() {
        if let containerView = containerView, !dimmingView.isDescendant(of: containerView) {
            containerView.insertSubview(dimmingView, at: 0)
            Constraint.activateGroup(dimmingView.equalToEdges(of: containerView))
        }
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        coordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        coordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
}

private final class InteractionController {
    private weak var interactiveController: BaseViewController?

    private(set) var percentController: UIPercentDrivenInteractiveTransition?

    init(interactiveController: BaseViewController) {
        self.interactiveController = interactiveController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        interactiveController.contentView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let interactiveView = sender.view else { return }
        let interactiveViewWidth = interactiveView.frame.size.width
        let fullWidth = interactiveViewWidth + SideMenuScene.configuration.rightOffset
        let ratio = interactiveViewWidth / fullWidth
        let translationX = sender.translation(in: interactiveView).x * ratio
        guard translationX <= 0 else {
            percentController?.cancel()
            percentController = nil
            return
        }
        let percent = abs(translationX) / interactiveViewWidth
        switch sender.state {
        case .began:
            percentController = UIPercentDrivenInteractiveTransition()
            interactiveController?.dismiss(animated: true)
            percentController?.update(percent)
        case .changed:
            percentController?.update(percent)
        default:
            percentController?.completionSpeed = 0.7
            if percent > 0.5 * 1/5 {
                percentController?.finish()
            } else {
                percentController?.cancel()
            }
            percentController = nil
        }
    }
}
