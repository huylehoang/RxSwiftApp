import RxSwift

protocol HomeUsecase: UsecaseType {
    func fetchNotes() -> Observable<[Note]>
}

struct DefaultHomeUsecase: HomeUsecase {
    private let service: NoteService

    init(service: NoteService = DefaultNoteService()) {
        self.service = service
    }

    func fetchNotes() -> Observable<[Note]> {
        // Reload user before fetch notes
        return service.reloadUser().asObservable().flatMap(fetch)
    }
}

private extension DefaultHomeUsecase {
    func fetch() -> Observable<[Note]> {
        // Call fetch notes then start notes listener
        // Retry 3 times for listener in case return error
        return service.fetchNotes().asObservable().concat(service.listenNotes().retry(3))
    }
}
