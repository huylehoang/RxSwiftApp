import RxSwift
import FirebaseAuth

protocol LoginUsecase: UsecaseType {
    func signIn(withEmail email: String, password: String) -> Single<Void>
    func signUp(withName name: String, email: String, password: String) -> Single<Void>
}

struct DefaultLoginUsecase: LoginUsecase {
    private let authService: AuthService
    private let meService: MeService

    init(
        authService: AuthService = DefaultAuthService(),
        meService: MeService = DefaultMeService()
    ) {
        self.authService = authService
        self.meService = meService
    }

    func signIn(withEmail email: String, password: String) -> Single<Void> {
        let signedIn = authService.signIn(withEmail: email, password: password)
            .flatMap(meService.create) // sync User to USERS table 
        let savePassword = { UserDefaults.setValue(password, forKey: .userPassword) }
        return signedIn.do(onSuccess: savePassword)
    }

    func signUp(withName name: String, email: String, password: String) -> Single<Void> {
        let signedUp = authService.createUser(withEmail: email, password: password)
            .map { (name, $0) }
            .flatMap(updateUserName)
            .flatMap(createMe)
        let savePassword = { UserDefaults.setValue(password, forKey: .userPassword) }
        return signedUp.do(onSuccess: savePassword)
    }
}

private extension DefaultLoginUsecase {
    func updateUserName(name: String, user: User) -> Single<Void> {
        return authService.updateUserName(name, for: user).catch(authService.deleteUser)
    }

    func createMe() -> Single<Void> {
        return meService.create().catch(authService.deleteUser)
    }
}
