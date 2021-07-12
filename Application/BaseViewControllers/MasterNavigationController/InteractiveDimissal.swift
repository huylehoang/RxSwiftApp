import UIKit

protocol InteractiveDimissal {
    var isInteractivelyDismissing: Bool { get set }
    var interactiveDismissAnimator: InteractiveAnimator? { get }
}
