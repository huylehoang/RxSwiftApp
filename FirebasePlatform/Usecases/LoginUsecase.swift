import RxSwift
import FirebaseAuth
import Domain

struct LoginUsecase: Domain.LoginUsecase {
    private let authService: AuthService
    private let profileService: ProfileService

    init(authService: AuthService, profileService: ProfileService) {
        self.authService = authService
        self.profileService = profileService
    }

    func signIn(withEmail email: String, password: String) -> Single<Void> {
        let signedIn = authService.signIn(withEmail: email, password: password)
            .flatMap(profileService.create) // sync User to USERS table
        let savePassword = { UserDefaults.setValue(password, forKey: .userPassword) }
        return signedIn.do(onSuccess: savePassword)
    }

    func signUp(withName name: String, email: String, password: String) -> Single<Void> {
        let signedUp = authService.createUser(withEmail: email, password: password)
            .map { (name, $0) }
            .flatMap(updateUserName)
            .flatMap(createProfile)
        let savePassword = { UserDefaults.setValue(password, forKey: .userPassword) }
        return signedUp.do(onSuccess: savePassword)
    }
}

private extension LoginUsecase {
    func updateUserName(name: String, user: User) -> Single<Void> {
        return authService.updateUserName(name, for: user).catch(authService.deleteUser)
    }

    func createProfile() -> Single<Void> {
        return profileService.create().catch(authService.deleteUser)
    }
}
