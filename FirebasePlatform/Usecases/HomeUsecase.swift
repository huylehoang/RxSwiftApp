import RxSwift
import Domain

struct HomeUsecase: Domain.HomeUsecase {
    private let noteService: NoteService
    private let profileService: ProfileService

    init(noteService: NoteService, profileService: ProfileService) {
        self.noteService = noteService
        self.profileService = profileService
    }

    func fetchNotes() -> Observable<[Note]> {
        // Reload user at first
        // Next, check User info is synced to USERS table
        // Then, check user password is still cached
        // Finally, fetch notes
        return noteService.reloadUser()
            .flatMap(profileService.load)
            .mapToVoid()
            .flatMap(checkUserPasswordStillValid)
            .asObservable()
            .flatMap(fetch)
    }

    func deleteNotes(_ notes: [Note]) -> Single<Void> {
        return noteService.deleteNotes(notes)
    }
}

private extension HomeUsecase {
    func fetch() -> Observable<[Note]> {
        // Call fetch notes then start notes listener
        // Retry 3 times for listener in case return error
        return noteService.fetchNotes().asObservable().concat(noteService.listenNotes().retry(3))
    }

    func checkUserPasswordStillValid() -> Single<Void> {
        return UserDefaults.getStringValue(forKey: .userPassword).mapToVoid()
    }
}
