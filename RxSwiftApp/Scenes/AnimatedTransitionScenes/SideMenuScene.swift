import UIKit

final class SideMenuScene: BaseViewController {
    struct Confirguration {
        let animateDuration: TimeInterval = 0.2
        let rightOffset: CGFloat = 50
        let backgroundColor: UIColor = UIColor(
            red: 33/255,
            green: 43/255,
            blue: 54/255,
            alpha: 0.76)
    }

    static var configuration = Confirguration()

    private weak var embeddedScene: UIViewController?

    init(embeddedScene: UIViewController) {
        super.init()
        self.embeddedScene = embeddedScene
        setupEmbeddedView()
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
        Constraint.activate(
            embeddedScene.view.leading.equalTo(contentView.leading),
            embeddedScene.view.trailing.equalTo(contentView.trailing),
            embeddedScene.view.top.equalTo(contentView.top),
            embeddedScene.view.bottom.equalTo(contentView.bottom))
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
        return SideMenuScene.configuration.animateDuration
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
        to.view.transform = CGAffineTransform(translationX: -to.view.frame.size.width, y: 1)
        UIView.animate(
            withDuration: SideMenuScene.configuration.animateDuration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                to.view.transform = .identity
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}

private final class DimissingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return SideMenuScene.configuration.animateDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let from = transitionContext.viewController(forKey: .from) else { return }
        UIView.animate(
            withDuration: SideMenuScene.configuration.animateDuration,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseIn,
            animations: {
                from.view.transform = CGAffineTransform(
                    translationX: -from.view.frame.size.width,
                    y: 1)
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            })
    }
}

private final class PresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SideMenuScene.configuration.backgroundColor
        view.alpha = 0.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            containerView.insertSubview(dimmingView, at: 0)
            Constraint.activate(
                dimmingView.top.equalTo(containerView.top),
                dimmingView.leading.equalTo(containerView.leading),
                dimmingView.trailing.equalTo(containerView.trailing),
                dimmingView.bottom.equalTo(containerView.bottom))
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
}

private extension PresentationController {
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
}
