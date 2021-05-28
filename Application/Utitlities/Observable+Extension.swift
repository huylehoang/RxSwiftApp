import RxSwift
import RxCocoa

extension SharedSequenceConvertibleType {
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
}
//
//extension PrimitiveSequenceType where Trait == SingleTrait {
//    func mapToVoid() -> Single<Void> {
//        return map { _ in }
//    }
//
//    func asDriver() -> Driver<Element> {
//        return asMaybe().asDriver { error in
//            return Driver.empty()
//        }
//    }
//}

extension ObservableType {
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
