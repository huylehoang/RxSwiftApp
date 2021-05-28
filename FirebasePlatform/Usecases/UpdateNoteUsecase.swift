import RxSwift
import Domain

public struct UpdateNoteUsecase: Domain.UpdateNoteUsecase {
    private let service: NoteService

    public init(service: NoteService = DefaultNoteService()) {
        self.service = service
    }

    public func addNote(_ note: Note) -> Single<Void> {
        return service.addNote(note)
    }

    public func updateNote(_ note: Note) -> Single<Void> {
        return service.updateNote(note)
    }

    public func deleteNote(_ note: Note) -> Single<Void> {
        return service.deleteNote(note)
    }
}
