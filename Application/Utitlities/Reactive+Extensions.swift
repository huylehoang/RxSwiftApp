import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewWillAppear)).mapToVoid())
    }

    var viewDidLoad: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidLoad)).mapToVoid())
    }

    var viewDidDisappear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidDisappear)).mapToVoid())
    }

    var touchesBegan: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.touchesBegan)).mapToVoid())
    }
}
