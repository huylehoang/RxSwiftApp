import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        return ControlEvent(events: self.sentMessage(#selector(Base.viewDidLoad)).mapToVoid())
    }

    var viewDidDisappear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidDisappear(_:))).mapToVoid())
    }
}
