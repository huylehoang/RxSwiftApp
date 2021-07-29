import UIKit

final class FadeZoomPercentDrivenController: PercentDrivenController {
    private weak var interactiveViewController: BaseViewController?

    private(set) var percentDriven: UIPercentDrivenInteractiveTransition?

    init(interactiveViewController: BaseViewController) {
        self.interactiveViewController = interactiveViewController
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        interactiveViewController.contentView.addGestureRecognizer(panGesture)
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
            interactiveViewController?.navigationController?.popViewController(animated: true)
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
