import RxSwift

protocol HomeUsecase: UsecaseType {
    func getAllNoteTitles() -> Single<[Note]>
    func listenNoteTitlesUpdate() -> Observable<[Note]>
}

struct DefaultHomeUsecase: HomeUsecase {
    private let service: NoteService

    init(service: NoteService = DefaultNoteService()) {
        self.service = service
    }

    func getAllNoteTitles() -> Single<[Note]> {
        return service.getAllNotes()
    }

    func listenNoteTitlesUpdate() -> Observable<[Note]> {
        return service.listenNotesUpdate()
    }
}


