import RxSwift
import RxCocoa

struct HomeViewModel: ViewModelType {
    struct Input {
        let viewDidLoad: Driver<Void>
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
        let listenerErrorMessage: Driver<String>
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
        let listenerErrorTracker = ErrorTracker()
        let notes = BehaviorRelay(value: [Note]())

        let fetchedNotes = input.viewDidLoad
            .map { (indicator, errorTracker) }
            .flatMapLatest(getAllNoteTitles)

        let updatedNotes = fetchedNotes
            .mapToVoid()
            .asObservable()
            .map { listenerErrorTracker }
            .flatMapLatest(listenNoteTitlesUpdate)
            .asDriverOnErrorJustComplete()

        let onFetchNoteTitles = Driver.merge(fetchedNotes, updatedNotes)
            .do(onNext: notes.accept)
            .mapToVoid()

        let toUser = input.toUserTrigger.do(onNext: navigator.toUser)

        let toAddNote = input.toAddNoteTrigger.do(onNext: navigator.toAddNote)

        let toEditNote = input.itemSelected
            .map { $0.row }
            .withLatestFrom(notes.asDriver(), resultSelector: getNote)
            .compactMap { $0 }
            .do(onNext: navigator.toEditNote)
            .mapToVoid()

        let onAction = Driver.merge(onFetchNoteTitles, toUser, toAddNote, toEditNote)

        let title = Driver.just("Notes")

        let outputNoteTitles = notes.asDriver().map { $0.titles() }.skip(1).distinctUntilChanged()

        let emptyMessage = outputNoteTitles.map { $0.isEmpty ? "Empty Notes" : "" }

        let embeddedIndicator = indicator.asDriver()

        let errorMessage = errorTracker.map { $0.localizedDescription }.asDriver()

        let listenerErrorMessage = listenerErrorTracker
            .map { $0.localizedDescription }
            .asDriver()

        return Output(
            title: title,
            noteTitles: outputNoteTitles,
            onAction: onAction,
            emptyMessage: emptyMessage,
            embeddedIndicator: embeddedIndicator,
            errorMessage: errorMessage,
            listenerErrorMessage: listenerErrorMessage)
    }
}

private extension HomeViewModel {
    func getAllNoteTitles(
        indicator: ActivityIndicator,
        errorTracker: ErrorTracker
    ) -> Driver<[Note]> {
        return usecase.getAllNoteTitles()
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func listenNoteTitlesUpdate(errorTracker: ErrorTracker) -> Observable<[Note]> {
        // Retry unlimited in case listener return error
        return usecase.listenNoteTitlesUpdate().trackError(errorTracker).retry()
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
