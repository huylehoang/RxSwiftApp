import Foundation
import RxSwift
import RxCocoa

final class UserViewModel: ViewModelType {
    struct Input {
        let signOutTrigger: Driver<Void>
    }

    struct Output {
        let uid: Driver<String>
        let displayName: Driver<String>
        let email: Driver<String>
        let onSignOut: Driver<Void>
        let errorMessage: Driver<String>
    }

    private let usecase: UserUsecase
    private let navigator: UserNavigator

    init(usecase: UserUsecase, navigator: UserNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let user = Driver.of(usecase.getUser()).compactMap { $0 }
        let uid = user.map { "UID: \($0.uid)" }
        let displayName = user.compactMap { $0.displayName }.map { "Name: \($0)" }
        let email = user.compactMap { $0.email }.map { "Email: \($0)" }

        let onSignOut = input.signOutTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.signOut()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: navigator.toLogin)
            .mapToVoid()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            uid: uid,
            displayName: displayName,
            email: email,
            onSignOut: onSignOut,
            errorMessage: errorMessage)
    }
}

private extension UserViewModel {
    func signOut() -> Observable<Void> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            if let error = self.usecase.signOut() {
                observer.onError(error)
            } else {
                observer.onNext(())
            }
            return Disposables.create()
        }
    }
}
