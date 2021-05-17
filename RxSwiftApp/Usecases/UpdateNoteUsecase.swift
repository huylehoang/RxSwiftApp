import RxSwift

protocol UpdateNoteUsecase {
    func addNote(_ note: Note) -> Single<Void>
    func updateNote(_ note: Note) -> Single<Void>
    func deleteNote(_ note: Note) -> Single<Void>
}

struct DefaultUpdateNoteUsecase: UpdateNoteUsecase {
    private let service: NoteService

    init(service: NoteService = DefaultNoteService()) {
        self.service = service
    }

    func addNote(_ note: Note) -> Single<Void> {
        return service.addNote(note)
    }

    func updateNote(_ note: Note) -> Single<Void> {
        return service.updateNote(note)
    }

    func deleteNote(_ note: Note) -> Single<Void> {
        return service.deleteNote(note)
    }
}
