import UIKit

protocol PercentDrivenController {
    var percentDriven: PercentDrivenAnimator? { get }
}

protocol PercentDrivenDimissal {
    var percentDrivenDismissAnimator: PercentDrivenAnimator? { get }
}
