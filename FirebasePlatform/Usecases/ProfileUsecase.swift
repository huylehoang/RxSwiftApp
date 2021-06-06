import RxSwift
import Domain

struct ProfileUsecase: Domain.ProfileUsecase {
    private let authService: AuthService
    private let profileService: ProfileService
    private let noteService: NoteService

    init(authService: AuthService, profileService: ProfileService, noteService: NoteService) {
        self.authService = authService
        self.profileService = profileService
        self.noteService = noteService
    }

    func getUserProfile() -> Single<Profile> {
        return authService.getUser().map(FirebaseHelper.convertUserToProfile)
    }

    func reAuthenticate() -> Single<Profile> {
        return Observable.combineLatest(email, password)
            .asSingle()
            .flatMap(authService.reAuthenticate)
            .map(FirebaseHelper.convertUserToProfile)
    }

    func deleteUser() -> Single<Void> {
        return reAuthenticate()
            .mapToVoid() // Re-Authenticate before process deleting user
            .flatMap(noteService.fetchNotes)
            .flatMap(noteService.deleteNotes)
            .flatMap(profileService.delete)
            .flatMap(authService.deleteUser)
            .do(onSuccess: UserDefaults.removeAllValues)
    }

    func signOut() -> Single<Void> {
        return authService.signOut().do(onSuccess: UserDefaults.removeAllValues)
    }
}

private extension ProfileUsecase {
    var email: Observable<String> {
        return getUserProfile().asObservable().compactMap { $0.mail }
    }

    var password: Observable<String> {
        return UserDefaults.getStringValue(forKey: .userPassword).asObservable()
    }
}
