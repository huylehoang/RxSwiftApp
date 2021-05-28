import RxSwift

public protocol ProfileUsecase: UsecaseType {
    func getUserProfile() -> Single<Profile>
    func reAuthenticate() -> Single<Profile>
    func deleteUser() -> Single<Void>
    func signOut() -> Single<Void>
}
