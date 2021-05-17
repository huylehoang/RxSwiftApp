import RxSwift
import RxCocoa
import FirebaseAuth

struct UserViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let reAuthenticateTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
        let signOutTrigger: Driver<Void>
    }

    struct Output {
        let onAction: Driver<Void>
        let showToast: Driver<String>
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

        let onGetUser = input.viewDidLoad
            .map { errorTracker }
            .flatMapLatest(getUser)

        let onReAuthenticated = input.reAuthenticateTrigger
            .map { (indicator, errorTracker) }
            .flatMapLatest(reAuthenticate)

        let onDeleted = input.deleteTrigger
            .map { (indicator, errorTracker) }
            .flatMapLatest(deleteUser)
            .mapToVoid()

        let onSignOut = input.signOutTrigger
            .map { errorTracker }
            .flatMapLatest(signOut)

        let toLogin = Driver.merge(onDeleted, onSignOut).do(onNext: navigator.toLogin)

        let onAction = Driver.merge(onReAuthenticated.mapToVoid(), toLogin)

        let showToast = Driver.merge(
            onReAuthenticated.map { _ in "Re-Authenticated" },
            onDeleted.map { "Deleted User" },
            onSignOut.map { "Signed Out" })

        let user = Driver.merge(onGetUser, onReAuthenticated)

        let displayName = user
            .compactMap { $0.displayName }
            .map { "Name: \($0)" }
            .distinctUntilChanged()

        let email = user
            .compactMap { $0.email }
            .map { "Email: \($0)" }
            .distinctUntilChanged()

        let embeddedLoading = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            onAction: onAction,
            showToast: showToast,
            displayName: displayName,
            email: email,
            embeddedLoading: embeddedLoading,
            errorMessage: errorMessage)
    }
}

private extension UserViewModel {
    func getUser(_ errorTracker: ErrorTracker) -> Driver<User> {
        return usecase.getUser()
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func reAuthenticate(indicator: ActivityIndicator, errorTracker: ErrorTracker) -> Driver<User> {
        return usecase.reAuthenticate()
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func deleteUser(indicator: ActivityIndicator, errorTracker: ErrorTracker) -> Driver<Void> {
        return usecase.deleteUser()
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func signOut(_ errorTracker: ErrorTracker) -> Driver<Void> {
        return usecase.signOut()
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
