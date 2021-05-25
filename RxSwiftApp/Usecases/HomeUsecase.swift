import RxSwift

protocol HomeUsecase: UsecaseType {
    func fetchNotes() -> Observable<[Note]>
}

struct DefaultHomeUsecase: HomeUsecase {
    private let noteService: NoteService
    private let meService: MeService

    init(
        noteService: NoteService = DefaultNoteService(),
        meService: MeService = DefaultMeService()
    ) {
        self.noteService = noteService
        self.meService = meService
    }

    func fetchNotes() -> Observable<[Note]> {
        // Reload user at first
        // Next, check User info is synced to USERS table
        // Then, check user password is still cached
        // Finally, fetch notes
        return noteService.reloadUser()
            .flatMap(meService.load)
            .flatMap(checkUserPasswordStillValid)
            .asObservable()
            .flatMap(fetch)
    }
}

private extension DefaultHomeUsecase {
    func fetch() -> Observable<[Note]> {
        // Call fetch notes then start notes listener
        // Retry 3 times for listener in case return error
        return noteService.fetchNotes().asObservable().concat(noteService.listenNotes().retry(3))
    }

    func checkUserPasswordStillValid() -> Single<Void> {
        return UserDefaults.getStringValue(forKey: .userPassword).mapToVoid()
    }
}
