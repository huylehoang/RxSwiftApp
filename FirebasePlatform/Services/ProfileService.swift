import FirebaseFirestore
import RxSwift
import Domain

public protocol ProfileService: CommonService {
    func create() -> Single<Void>
    func load() -> Single<Profile>
    func delete() -> Single<Void>
}

public struct DefaultProfileService: ProfileService {
    private let firestore = Observable.just(Firestore.firestore())

    private var profile: Observable<Profile> {
        return getUser().map(FirebaseHelper.convertUserToProfile).asObservable()
    }

    private var usersCollection: Observable<CollectionReference> {
        return firestore.map { $0.collection("USERS") }
    }

    private var credentail: Single<(Profile, CollectionReference)> {
        return Observable.combineLatest(profile, usersCollection).asSingle()
    }

    public init() {}

    public func create() -> Single<Void> {
        return credentail.flatMap(create)
    }

    public func load() -> Single<Profile> {
        return credentail.flatMap(load)
    }

    public func delete() -> Single<Void> {
        return credentail.flatMap(delete)
    }
}

private extension DefaultProfileService {
    func create(_ profile: Profile, for usersCollection: CollectionReference) -> Single<Void> {
        return .create { single in
            usersCollection.document(profile.id).setData(profile.data) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func load(_ profile: Profile, for usersCollection: CollectionReference) -> Single<Profile> {
        return .create { single in
            usersCollection.document(profile.id).getDocument { snapshot, error in
                guard error == nil, let snapshot = snapshot else {
                    single(.failure(ServiceError.userNotSync))
                    return
                }
                let loadedProfile = FirebaseHelper.convertSnapshotToProfile(snapshot: snapshot)
                guard loadedProfile == profile else {
                    single(.failure(ServiceError.userNotSync))
                    return
                }
                single(.success(loadedProfile))
            }
            return Disposables.create()
        }
    }

    func delete(_ profile: Profile, for usersCollection: CollectionReference) -> Single<Void> {
        return .create { single in
            usersCollection.document(profile.id).delete { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
}
