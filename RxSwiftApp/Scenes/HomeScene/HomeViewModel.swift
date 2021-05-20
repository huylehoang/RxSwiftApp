import RxSwift
import RxCocoa

struct HomeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let refreshTrigger: Driver<Void>
        let toAddNoteTrigger: Driver<Void>
        let toUserTrigger: Driver<Void>
        let itemSelected: Driver<IndexPath>
    }

    struct Output {
        let title: Driver<String>
        let noteTitles: Driver<[String]>
        let onAction: Driver<Void>
        let emptyMessage: Driver<String>
        let embeddedIndicator: Driver<Bool>
        let errorMessage: Driver<String>
    }

    private let usecase: HomeUsecase
    private let navigator: HomeNavigator

    init(usecase: HomeUsecase, navigator: HomeNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let indicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let notes = BehaviorRelay(value: [Note]())

        let fetchedNotes = Driver.merge(input.viewDidLoad, input.refreshTrigger)
            .map { (indicator, errorTracker) }
            .flatMapLatest(fetchNotes)
            .do(onNext: notes.accept)
            .mapToVoid()

        let toLogin = errorTracker
            .filter { $0.userNotFound }
            .mapToVoid()
            .do(onNext: navigator.toLogin)

        let toUser = input.toUserTrigger.do(onNext: navigator.toUser)

        let toAddNote = input.toAddNoteTrigger.do(onNext: navigator.toAddNote)

        let toEditNote = input.itemSelected
            .map { $0.row }
            .withLatestFrom(notes.asDriver(), resultSelector: getNote)
            .compactMap { $0 }
            .do(onNext: navigator.toEditNote)
            .mapToVoid()

        let onAction = Driver.merge(toLogin, toUser, toAddNote, toEditNote)

        let title = Driver.just("Notes")

        let outputNoteTitles = Driver.merge(fetchedNotes, errorTracker.mapToVoid())
            .withLatestFrom(notes.asDriver())
            .map { $0.titles() }

        let emptyMessage = outputNoteTitles.map { $0.isEmpty ? "Empty Notes" : "" }

        let embeddedIndicator = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            title: title,
            noteTitles: outputNoteTitles,
            onAction: onAction,
            emptyMessage: emptyMessage,
            embeddedIndicator: embeddedIndicator,
            errorMessage: errorMessage)
    }
}

private extension HomeViewModel {
    func fetchNotes(indicator: ActivityIndicator, errorTracker: ErrorTracker) -> Driver<[Note]> {
        return usecase.fetchNotes()
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func getNote(at index: Int, from notes: [Note]) -> Note? {
        guard index >= 0 && index < notes.count else { return nil }
        return notes[index]
    }
}

private extension Sequence where Element == Note {
    func titles() -> [String] {
        return map { $0.title }
    }
}
