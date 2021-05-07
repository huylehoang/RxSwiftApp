import Foundation
import RxSwift
import RxCocoa

struct UserViewModel: ViewModelType {
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
            .map { (indicator, errorTracker) }
            .flatMapLatest(reAuthenticate)
            .do()

        let onDelete = input.deleteTrigger
            .map { (indicator, errorTracker) }
            .flatMapLatest(deleteUser)
            .do(onNext: navigator.toLogin)

        let onSignOut = input.signOutTrigger
            .map { errorTracker }
            .flatMapLatest(signOut)
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

private extension UserViewModel {
    func reAuthenticate(
        _ credential: (indicator: ActivityIndicator, errorTracker: ErrorTracker)
    ) -> Driver<Void> {
        return usecase.reAuthenticate()
            .trackActivity(credential.indicator)
            .trackError(credential.errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func deleteUser(
        _ credential: (indicator: ActivityIndicator, errorTracker: ErrorTracker)
    ) -> Driver<Void> {
        return usecase.deleteUser()
            .trackActivity(credential.indicator)
            .trackError(credential.errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func signOut(_ errorTracker: ErrorTracker) -> Driver<Void> {
        return usecase.signOut()
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
