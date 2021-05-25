import RxSwift
import RxCocoa

struct HomeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
        let emptyRefreshTrigger: Driver<Void>
        let refreshTrigger: Driver<Void>
        let toAddNoteTrigger: Driver<Void>
        let toUserTrigger: Driver<Void>
        let itemSelected: Driver<IndexPath>
    }

    struct Output {
        let title: Driver<String>
        let noteTitles: Driver<[String]>
        let isEmpty: Driver<Bool>
        let emptyMessage: Driver<String>
        let embeddedLoading: Driver<Bool>
        let refreshLoading: Driver<Bool>
        let errorMessage: Driver<String>
        let onAction: Driver<Void>
    }

    private let usecase: HomeUsecase
    private let navigator: HomeNavigator

    init(usecase: HomeUsecase, navigator: HomeNavigator) {
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let embeddedIndicator = ActivityIndicator()
        let refreshIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let notes = BehaviorRelay(value: [Note]())

        let embeddedLoadingTrigger = Driver.merge(input.viewDidLoad, input.emptyRefreshTrigger)
            .map { (embeddedIndicator, refreshIndicator, errorTracker) }

        let refreshLoadingTrigger = input.refreshTrigger
            .map { (refreshIndicator, embeddedIndicator, errorTracker) }

        let fetchedNotes = Driver.merge(embeddedLoadingTrigger, refreshLoadingTrigger)
            .flatMapLatest(fetchNotes)
            .do(onNext: notes.accept)
            .mapToVoid()

        let toLogin = errorTracker
            .filter { $0.forceSignOut }
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

        let title = Driver.just("Notes")

        let outputNoteTitles = Driver.merge(fetchedNotes, errorTracker.mapToVoid())
            .withLatestFrom(notes.asDriver())
            .map { $0.titles() }

        let isEmpty = outputNoteTitles.map { $0.isEmpty }

        let emptyMessage = isEmpty.map { $0 ? "Empty Notes" : "" }

        let embeddedLoading = embeddedIndicator.asDriver()

        let refreshLoading = refreshIndicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        let onAction = Driver.merge(toLogin, toUser, toAddNote, toEditNote)

        return Output(
            title: title,
            noteTitles: outputNoteTitles,
            isEmpty: isEmpty,
            emptyMessage: emptyMessage,
            embeddedLoading: embeddedLoading,
            refreshLoading: refreshLoading,
            errorMessage: errorMessage,
            onAction: onAction)
    }
}

private extension HomeViewModel {
    func fetchNotes(
        indicator: ActivityIndicator,
        forcedStopIndicator: ActivityIndicator,
        errorTracker: ErrorTracker
    ) -> Driver<[Note]> {
        return usecase.fetchNotes()
            .trackActivity(indicator)
            .forceStopLoading(forcedStopIndicator)
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
