import RxSwift
import FirebaseAuth

protocol UserUsecase: UsecaseType {
    func getUser() -> Single<User>
    func reAuthenticate() -> Single<User>
    func deleteUser() -> Single<Void>
    func signOut() -> Single<Void>
}

struct DefaultUserUsecase: UserUsecase {
    private let authService: AuthService
    private let meService: MeService
    private let noteService: NoteService

    init(
        authService: AuthService = DefaultAuthService(),
        meService: MeService = DefaultMeService(),
        noteService: NoteService = DefaultNoteService()
    ) {
        self.authService = authService
        self.meService = meService
        self.noteService = noteService
    }

    func getUser() -> Single<User> {
        return authService.getUser()
    }

    func reAuthenticate() -> Single<User> {
        return Observable.combineLatest(email, password)
            .asSingle()
            .flatMap(authService.reAuthenticate)
    }

    func deleteUser() -> Single<Void> {
        return noteService.deleteNotes()
            .flatMap(meService.delete)
            .flatMap(authService.deleteUser)
            .do(onSuccess: UserDefaults.removeAllValues)
    }

    func signOut() -> Single<Void> {
        return authService.signOut().do(onSuccess: UserDefaults.removeAllValues)
    }
}

private extension DefaultUserUsecase {
    var email: Observable<String> {
        return getUser().asObservable().compactMap { $0.email }
    }

    var password: Observable<String> {
        return UserDefaults.getStringValue(forKey: .userPassword).asObservable()
    }
}
