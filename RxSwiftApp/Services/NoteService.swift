import FirebaseFirestore
import RxSwift

protocol NoteService: ServiceType {
    func getAllNotes() -> Single<[Note]>
    func listenNotesUpdate() -> Observable<[Note]>
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

    func getAllNotes() -> Single<[Note]> {
        return userNotes.flatMap(getAllNotes)
    }

    func listenNotesUpdate() -> Observable<[Note]> {
        return userNotes.asObservable().flatMap(listenNotesUpdate)
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
    func getAllNotes(of userNotes: CollectionReference) -> Single<[Note]> {
        return .create { single in
            userNotes.getDocuments { querySnapshot, error in
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

    func listenNotesUpdate(of userNotes: CollectionReference) -> Observable<[Note]> {
        return .create { observer in
            let listener = userNotes.addSnapshotListener { querySnapshot, error in
                if let snapshots = querySnapshot?.documents {
                    observer.onNext(snapshots.map(Note.init))
                } else if let error = error {
                    observer.onError(error)
                } else {
                    observer.onError(ServiceError.somethingWentWrong)
                }
            }
            return Disposables.create {
                listener.remove()
            }
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
