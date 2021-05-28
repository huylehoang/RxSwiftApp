import RxSwift

public protocol LoginUsecase: UsecaseType {
    func signIn(withEmail email: String, password: String) -> Single<Void>
    func signUp(withName name: String, email: String, password: String) -> Single<Void>
}
