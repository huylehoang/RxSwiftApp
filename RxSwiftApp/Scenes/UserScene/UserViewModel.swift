import Foundation
import RxSwift
import RxCocoa

final class UserViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let reAuthenticateTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let signOutTrigger: Driver<Void>
    }

    struct Output {
        let onReAuthenticate: Driver<Void>
        let onDelete: Driver<Void>
        let onSignOut: Driver<Void>
        let uid: Driver<String>
        let displayName: Driver<String>
        let email: Driver<String>
        let embeddedLoading: Driver<Bool>
        let errorMessage: Driver<String>
    }

    private let usecase: UserUsecase
    private let navigator: UserNavigator

    init(usecase: UserUsecase, navigator: UserNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let indicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let onReAuthenticate = input.reAuthenticateTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.usecase.reAuthenticate()
                    .trackActivity(indicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do()

        let onDelete = input.deleteTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.usecase.deleteUser()
                    .trackActivity(indicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: navigator.toLogin)

        let onSignOut = input.signOutTrigger
            .flatMapLatest { [weak self] _ -> Driver<Void> in
                guard let self = self else { return .empty() }
                return self.usecase.signOut()
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .do(onNext: navigator.toLogin)

        let user = Driver.merge(input.viewDidLoad, onReAuthenticate)
            .withLatestFrom(usecase.getUser().asDriverOnErrorJustComplete())

        let uid = user.withLatestFrom(user).map { "UID: \($0.uid)" }

        let displayName = user.compactMap { $0.displayName }.map { "Name: \($0)" }

        let email = user.compactMap { $0.email }.map { "Email: \($0)" }

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            onReAuthenticate: onReAuthenticate,
            onDelete: onDelete,
            onSignOut: onSignOut,
            uid: uid,
            displayName: displayName,
            email: email,
            embeddedLoading: embeddedLoading,
            errorMessage: errorMessage)
    }
}
