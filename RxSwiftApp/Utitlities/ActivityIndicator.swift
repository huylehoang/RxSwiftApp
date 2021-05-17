import RxSwift
import RxCocoa

final class ActivityIndicator: SharedSequenceConvertibleType {
    typealias Element = Bool
    typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _behavior = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _behavior.asDriver().map { $0 > 0 }.distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(
        _ source: O
    ) -> Observable<O.Element> {
        return source.asObservable()
            .do(onNext: { _ in
                self.decrement()
            }, onError: { _ in
                self.decrement()
            }, onCompleted: {
                self.decrement()
            },
            onSubscribe: increment,
            onDispose: decrement)
    }

    private func increment() {
        _lock.lock()
        _behavior.accept(_behavior.value + 1)
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _behavior.accept(max(0, _behavior.value - 1))
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
