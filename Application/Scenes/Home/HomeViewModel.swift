import RxSwift
import RxCocoa
import Domain

struct HomeViewModel: ViewModelType {
    typealias Item = HomeScene.CellViewModel

    struct Input {
        let viewDidLoad: Driver<Void>
        let emptyRefreshTrigger: Driver<Void>
        let refreshTrigger: Driver<Void>
        let toAddNoteTrigger: Driver<Void>
        let toProfileTrigger: Driver<Void>
        let selectAllTrigger: Driver<Void>
        let cancelTrigger: Driver<Void>
        let itemSelected: Driver<Item>
        let itemChecked: Driver<Item>
        let itemUnchecked: Driver<Item>
        let deleteTrigger: Driver<Void>
    }

    struct Output {
        let embeddedLoading: Driver<Bool>
        let embeddedLoadingView: Driver<Bool>
        let refreshLoading: Driver<Bool>
        let enableDelete: Driver<Bool>
        let isSelectingAll: Driver<Bool>
        let items: Driver<[Item]>
        let disableSelectAll: Driver<Bool>
        let title: Driver<String>
        let isEmpty: Driver<Bool>
        let emptyMessage: Driver<String>
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
        let embeddedInddicatorView = ActivityIndicator()
        let refreshIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        let items = BehaviorRelay(value: [Item]())

        let embeddedLoading = embeddedIndicator.asDriver()

        let embeddedLoadingView = embeddedInddicatorView.asDriver()

        let refreshLoading = refreshIndicator.asDriver()

        let embeddedLoadingTrigger = Driver.merge(input.viewDidLoad, input.emptyRefreshTrigger)
            .map { (embeddedIndicator, refreshIndicator, errorTracker) }

        let refreshLoadingTrigger = input.refreshTrigger
            .map { (refreshIndicator, embeddedIndicator, errorTracker) }

        let fetchedNotes = Driver.merge(embeddedLoadingTrigger, refreshLoadingTrigger)
            .flatMapLatest(fetchNotes)
            .map(toItem)
            .do(onNext: items.accept)
            .mapToVoid()

        let toLogin = errorTracker
            .compactMap { $0 as? ErrorType }
            .filter { $0.forceSignOut }
            .mapToVoid()
            .do(onNext: navigator.toLogin)

        let toProfile = input.toProfileTrigger.do(onNext: navigator.toProfile)

        let toAddNote = input.toAddNoteTrigger.do(onNext: navigator.toAddNote)

        let toEditNote = input.itemSelected
            .map { $0.note }
            .map(UpdateNoteViewModel.NoteViewModel.init)
            .do(onNext: navigator.toEditNote)
            .mapToVoid()

        let onNoteSelected = input.itemChecked
            .withLatestFrom(items.asDriver(), resultSelector: checkedItem)
            .do(onNext: items.accept)
            .mapToVoid()

        let onNoteDeselected = input.itemUnchecked
            .withLatestFrom(items.asDriver(), resultSelector: uncheckedItem)
            .do(onNext: items.accept)
            .mapToVoid()

        let selectedNotes = items.asDriver().map { $0.selectedNotes() }

        let enableDelete = selectedNotes.map { !$0.isEmpty }

        let onDeleteNotes = input.deleteTrigger
            .withLatestFrom(enableDelete)
            .filter { $0 }
            .withLatestFrom(selectedNotes)
            .map { ($0, embeddedInddicatorView, errorTracker) }
            .flatMapLatest(deleteNotes)
            .mapToVoid()

        let isSelectingAll = Driver.merge(
            input.selectAllTrigger.map { true },
            input.itemSelected.map { _ in false },
            input.cancelTrigger.map { false },
            input.refreshTrigger.map { false },
            input.toAddNoteTrigger.map { false },
            onDeleteNotes.map { false })
            .startWith(false)
            .distinctUntilChanged()

        let onRemoveAllSelectedNotes = isSelectingAll
            .filter { !$0 }
            .withLatestFrom(items.asDriver())
            .map(uncheckedAllItems)
            .do(onNext: items.accept)
            .mapToVoid()

        let outputItems = Driver.merge(
            fetchedNotes,
            onRemoveAllSelectedNotes.skip(1),
            errorTracker.mapToVoid())
            .withLatestFrom(items.asDriver())

        let disableSelectAll = Driver.merge(
            embeddedLoading,
            refreshLoading,
            outputItems.map { $0.isEmpty })

        let title = Driver.just("Notes")

        let isEmpty = outputItems.map { $0.isEmpty }

        let emptyMessage = isEmpty.map { $0 ? "Empty Notes" : "" }

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        let onAction = Driver.merge(
            toLogin,
            toProfile,
            toAddNote,
            toEditNote,
            onNoteSelected,
            onNoteDeselected,
            onDeleteNotes)

        return Output(
            embeddedLoading: embeddedLoading,
            embeddedLoadingView: embeddedLoadingView,
            refreshLoading: refreshLoading,
            enableDelete: enableDelete,
            isSelectingAll: isSelectingAll,
            items: outputItems,
            disableSelectAll: disableSelectAll,
            title: title,
            isEmpty: isEmpty,
            emptyMessage: emptyMessage,
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

    func deleteNotes(
        _ notes: [Note],
        indicator: ActivityIndicator,
        errorTracker: ErrorTracker
    ) -> Driver<Void> {
        return usecase.deleteNotes(notes)
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func toItem(from notes: [Note]) -> [Item] {
        return notes.map(Item.init)
    }

    func checkedItem(_ item: Item, from items: [Item]) -> [Item] {
        return handleItemSelection(item: item, isSelected: true, from: items)
    }

    func uncheckedItem(_ item: Item, from items: [Item]) -> [Item] {
        return handleItemSelection(item: item, isSelected: false, from: items)
    }

    func handleItemSelection(
        item: Item,
        isSelected: Bool,
        from items: [Item]
    ) -> [Item] {
        guard let index = items.firstIndex(where: { $0.note.id == item.note.id }) else {
            return items
        }
        var mutableItems = items
        mutableItems[index] = item.updated { $0.isSelected = isSelected }
        return mutableItems
    }

    func uncheckedAllItems(from items: [Item]) -> [Item] {
        return items.reduce(into: [Item]()) { items, item in
            items.append(item.updated { $0.isSelected = false })
        }
    }
}

private extension Sequence where Element == HomeViewModel.Item {
    func selectedNotes() -> [Note] {
        return filter { $0.isSelected }.map { $0.note }
    }
}
