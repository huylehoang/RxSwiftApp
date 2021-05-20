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
        // Then check User info is synced to USERS table
        // Finally, fetch notes
        return noteService.reloadUser().flatMap(meService.load).asObservable().flatMap(fetch)
    }
}

private extension DefaultHomeUsecase {
    func fetch() -> Observable<[Note]> {
        // Call fetch notes then start notes listener
        // Retry 3 times for listener in case return error
        return noteService.fetchNotes().asObservable().concat(noteService.listenNotes().retry(3))
    }
}
