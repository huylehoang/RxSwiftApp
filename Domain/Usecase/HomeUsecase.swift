import RxSwift

public protocol HomeUsecase: UsecaseType {
    func fetchNotes() -> Observable<[Note]>
}
