import Foundation
import RxSwift
import RxCocoa

struct UserViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let reAuthenticateTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let signOutTrigger: Driver<Void>
        let confirmDelete: Driver<Void>
    }

    struct Output {
        let notiReAuthenticated: Driver<Void>
        let notiDeleted: Driver<Void>
        let onAction: Driver<Void>
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

        let notiReAuthenticated = input.reAuthenticateTrigger
            .map { (indicator, errorTracker) }
            .flatMapLatest(reAuthenticate)

        let notiDeleted = input.deleteTrigger
            .map { (indicator, errorTracker) }
            .flatMapLatest(deleteUser)

        let onSignOut = input.signOutTrigger
            .map { errorTracker }
            .flatMapLatest(signOut)
            .do(onNext: navigator.toLogin)

        let onConfirmDeleted = input.confirmDelete.do(onNext: navigator.toLogin)

        let onAction = Driver.merge(onSignOut, onConfirmDeleted)

        let user = Driver.merge(input.viewDidLoad, notiReAuthenticated)
            .withLatestFrom(usecase.getUser().asDriverOnErrorJustComplete())

        let uid = user.withLatestFrom(user).map { "UID: \($0.uid)" }

        let displayName = user.compactMap { $0.displayName }.map { "Name: \($0)" }

        let email = user.compactMap { $0.email }.map { "Email: \($0)" }

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            notiReAuthenticated: notiReAuthenticated,
            notiDeleted: notiDeleted,
            onAction: onAction,
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
