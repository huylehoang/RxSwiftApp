import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidDisappear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidDisappear(_:))).mapToVoid())
    }
}
