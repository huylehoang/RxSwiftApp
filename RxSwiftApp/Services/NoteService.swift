import FirebaseFirestore
import RxSwift

protocol NoteService: ServiceType {
    func fetchNotes() -> Single<[Note]>
    func listenNotes() -> Observable<[Note]>
    func deleteNotes() -> Single<Void>
    func addNote(_ note: Note) -> Single<Void>
    func updateNote(_ note: Note) -> Single<Void>
    func deleteNote(_ note: Note) -> Single<Void>
}

struct DefaultNoteService: NoteService {
    private let firestore = Observable.just(Firestore.firestore())

    private var userId: Observable<String> {
        return getUser().map { $0.uid }.asObservable()
    }

    private var userNotes: Single<CollectionReference> {
        return Observable.combineLatest(firestore, userId)
            .map { $0.collection("USERS").document($1).collection("NOTES") }
            .asSingle()
    }

    private var userNotesQuery: Single<Query> {
        return userNotes.map { $0.order(by: "timestamp", descending: true) }
    }

    func fetchNotes() -> Single<[Note]> {
        return userNotesQuery.flatMap(fetchNotes)
    }

    func listenNotes() -> Observable<[Note]> {
        return userNotesQuery.asObservable().flatMap(listenNotes)
    }

    func deleteNotes() -> Single<Void> {
        return userNotes.flatMap(deleteNotes)
    }

    func addNote(_ note: Note) -> Single<Void> {
        return userNotes.map { (note, $0) }.flatMap(setNote)
    }

    func updateNote(_ note: Note) -> Single<Void> {
        return userNotes.map { (note, $0) }.flatMap(updateNote)
    }

    func deleteNote(_ note: Note) -> Single<Void> {
        return userNotes.map { (note, $0) }.flatMap(deleteNote)
    }
}

private extension DefaultNoteService {
    func fetchNotes(of userNotesQuery: Query) -> Single<[Note]> {
        return .create { single in
            userNotesQuery.getDocuments { querySnapshot, error in
                if let snapshots = querySnapshot?.documents {
                    single(.success(snapshots.map(Note.init)))
                } else if let error = error {
                    single(.failure(error))
                } else {
                    single(.failure(ServiceError.somethingWentWrong))
                }
            }
            return Disposables.create()
        }
    }

    func listenNotes(of userNotesQuery: Query) -> Observable<[Note]> {
        return .create { observer in
            let listener = userNotesQuery.addSnapshotListener { querySnapshot, error in
                if let querySnapshot = querySnapshot, !querySnapshot.documentChanges.isEmpty {
                    let snapshots = querySnapshot.documents
                    observer.onNext(snapshots.map(Note.init))
                } else if let error = error {
                    observer.onError(error)
                }
            }
            return Disposables.create {
                listener.remove()
            }
        }
    }

    func deleteNotes(of userNotes: CollectionReference) -> Single<Void> {
        return .create { single in
            userNotes.getDocuments { querySnapshot, error in
                if let error = error {
                    single(.failure(error))
                } else {
                    querySnapshot?.documents.forEach {
                        userNotes.document($0.documentID).delete()
                    }
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func setNote(_ note: Note, for userNotes: CollectionReference) -> Single<Void> {
        return .create { single in
            userNotes.document().setData(note.data) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func updateNote(_ note: Note, for userNotes: CollectionReference) -> Single<Void> {
        return .create { single in
            guard let id = note.id else {
                single(.failure(ServiceError.noteNotFound))
                return Disposables.create()
            }
            userNotes.document(id).setData(note.data, merge: true) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func deleteNote(_ note: Note, for userNotes: CollectionReference) -> Single<Void> {
        return .create { single in
            guard let id = note.id else {
                single(.failure(ServiceError.noteNotFound))
                return Disposables.create()
            }
            userNotes.document(id).delete { error in
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
