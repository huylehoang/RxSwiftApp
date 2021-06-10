import RxSwift

public protocol HomeUsecase: UsecaseType {
    func fetchNotes() -> Observable<[Note]>
    func deleteNotes(_ notes: [Note]) -> Single<Void>
}
