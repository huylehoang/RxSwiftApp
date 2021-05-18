import RxSwift

protocol HomeUsecase: UsecaseType {
    func reloadUser() -> Single<Void>
    func fetchNotes() -> Observable<[Note]>
}

struct DefaultHomeUsecase: HomeUsecase {
    private let service: NoteService

    init(service: NoteService = DefaultNoteService()) {
        self.service = service
    }

    func reloadUser() -> Single<Void> {
        return service.reloadUser()
    }

    func fetchNotes() -> Observable<[Note]> {
        return service.fetchNotes().asObservable().concat(service.listenNotes())
    }
}


