import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidLoad)).mapToVoid())
    }

    var viewWillAppear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewWillAppear)).mapToVoid())
    }

    var viewWillDisappear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewWillDisappear)).mapToVoid())
    }

    var viewDidDisappear: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.viewDidDisappear)).mapToVoid())
    }
}

extension Reactive where Base: UITextField {
    var deleteBackward: ControlEvent<Void> {
        return ControlEvent(events: sentMessage(#selector(Base.deleteBackward)).mapToVoid())
    }
}
