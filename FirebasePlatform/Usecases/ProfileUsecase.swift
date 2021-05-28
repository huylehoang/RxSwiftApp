import RxSwift
import Domain

public struct ProfileUsecase: Domain.ProfileUsecase {
    private let authService: AuthService
    private let profileService: ProfileService
    private let noteService: NoteService

    public init(
        authService: AuthService = DefaultAuthService(),
        profileService: ProfileService = DefaultProfileService(),
        noteService: NoteService = DefaultNoteService()
    ) {
        self.authService = authService
        self.profileService = profileService
        self.noteService = noteService
    }

    public func getUserProfile() -> Single<Profile> {
        return authService.getUser().map(FirebaseHelper.convertUserToProfile)
    }

    public func reAuthenticate() -> Single<Profile> {
        return Observable.combineLatest(email, password)
            .asSingle()
            .flatMap(authService.reAuthenticate)
            .map(FirebaseHelper.convertUserToProfile)
    }

    public func deleteUser() -> Single<Void> {
        return reAuthenticate()
            .mapToVoid() // Re-Authenticate before process deleting user
            .flatMap(noteService.fetchNotes)
            .flatMap(noteService.deleteNotes)
            .flatMap(profileService.delete)
            .flatMap(authService.deleteUser)
            .do(onSuccess: UserDefaults.removeAllValues)
    }

    public func signOut() -> Single<Void> {
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
