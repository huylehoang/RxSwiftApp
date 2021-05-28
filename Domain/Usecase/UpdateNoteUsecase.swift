import RxSwift

public protocol UpdateNoteUsecase: UsecaseType {
    func addNote(_ note: Note) -> Single<Void>
    func updateNote(_ note: Note) -> Single<Void>
    func deleteNote(_ note: Note) -> Single<Void>
}
