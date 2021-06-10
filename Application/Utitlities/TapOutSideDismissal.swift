import UIKit
import RxSwift
import RxCocoa

protocol TapOutsideDimissal: UIView {
    func setupTapOutsideGesture()
    func removeTapOutsideGesture()
}

extension TapOutsideDimissal {
    fileprivate var tapOutsideManager: TapOutsideManager {
        guard let tapOutsideManager = objc_getAssociatedObject(
                self,
                &TapOutsideManager.context) as? TapOutsideManager
        else {
            let tapOutsideManager = TapOutsideManager(view: self)
            objc_setAssociatedObject(
                self,
                &TapOutsideManager.context,
                tapOutsideManager,
                .OBJC_ASSOCIATION_RETAIN)
            return tapOutsideManager
        }
        return tapOutsideManager
    }

    func setupTapOutsideGesture() {
        tapOutsideManager.setupGestures()
    }

    func removeTapOutsideGesture() {
        tapOutsideManager.removeGestures()
    }
}

extension Reactive where Base: TapOutsideDimissal {
    var tappedOutside: Observable<Void> {
        return base.tapOutsideManager.tappedOutside.asObservable()
    }
}

private final class TapOutsideManager: NSObject {
    static var context = 0

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    fileprivate let tappedOutside = PublishRelay<Void>()

    private let disposeBag = DisposeBag()

    private weak var view: UIView?

    init(view: UIView) {
        self.view = view
    }

    fileprivate func setupGestures() {
        view?.window?.addGestureRecognizer(tapGesture)
    }

    fileprivate func removeGestures() {
        view?.window?.removeGestureRecognizer(tapGesture)
    }

    @objc private func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        guard tapGesture.state == .ended else { return }
        removeGestures()
        tappedOutside.accept(())
    }
}

extension TapOutsideManager: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard let view = view, let window = UIApplication.shared.getWindow() else { return false }
        let point = touch.location(in: nil)
        let pointInSubview = view.convert(point, from: window)
        return !view.bounds.contains(pointInSubview)
    }
}
