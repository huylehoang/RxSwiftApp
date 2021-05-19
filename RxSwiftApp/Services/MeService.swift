import FirebaseFirestore
import RxSwift

protocol MeService: ServiceType {
    func create() -> Single<Void>
    func delete() -> Single<Void>
}

struct DefaultMeService: MeService {
    private let firestore = Observable.just(Firestore.firestore())

    private var me: Observable<Me> {
        return getUser().map(Me.init).asObservable()
    }

    private var usersCollection: Observable<CollectionReference> {
        return firestore.map { $0.collection("USERS") }
    }

    private var credentail: Single<(Me, CollectionReference)> {
        return Observable.combineLatest(me, usersCollection).asSingle()
    }

    func create() -> Single<Void> {
        return credentail.flatMap(create)
    }

    func delete() -> Single<Void> {
        return credentail.flatMap(delete)
    }
}

private extension DefaultMeService {
    func create(_ me: Me, for usersCollection: CollectionReference) -> Single<Void> {
        return .create { single in
            usersCollection.document(me.id).setData(me.data) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func delete(_ me: Me, for usersCollection: CollectionReference) -> Single<Void> {
        return .create { single in
            usersCollection.document(me.id).delete { error in
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
