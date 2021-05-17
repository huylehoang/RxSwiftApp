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
        return service.fetchNotes().asObservable().concat(service.listenNotes())
    }
}


