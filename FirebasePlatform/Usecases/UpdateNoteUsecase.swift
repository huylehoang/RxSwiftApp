import RxSwift
import Domain

struct UpdateNoteUsecase: Domain.UpdateNoteUsecase {
    private let service: NoteService

    init(service: NoteService) {
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
