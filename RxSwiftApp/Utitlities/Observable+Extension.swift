import Foundation
import RxSwift
import RxCocoa

extension ObservableType where Element == Bool {
    /// Boolean not operator
    public func not() -> Observable<Bool> {
        return self.map(!)
    }
}

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    func mapToVoid() -> Single<Void> {
        return map { _ in } 
    }

    func asDriver() -> Driver<Element> {
        return asMaybe().asDriver { error in
            return Driver.empty()
        }
    }
}

extension ObservableType {
    func catchErrorJustComplete() -> Observable<Element> {
        return catchError { _ in
            return Observable.empty()
        }
    }

    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    // Articles:
    // -  https://www.codementor.io/@otbivnoe/improvements-of-flatmap-function-in-rxswift-ej5bv8i9f
    func flatMap<WeakObj: AnyObject, Obs: ObservableType>(
        weak obj: WeakObj,
        selector: @escaping (WeakObj, Element) throws -> Obs
    ) -> Observable<Obs.Element> {
        return flatMap { [weak obj] element -> Observable<Obs.Element> in
            try obj.map { try selector($0, element).asObservable() } ?? .empty()
        }
    }
}
