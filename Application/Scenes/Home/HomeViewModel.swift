import RxSwift
import RxCocoa
import Domain

struct HomeViewModel: ViewModelType {
    typealias Item = HomeScene.CellViewModel

    struct Input {
        let viewDidLoad: Driver<Void>
        let viewWillDisappear: Driver<Void>
        let emptyRefreshTrigger: Driver<Void>
        let refreshTrigger: Driver<Void>
        let toAddNoteTrigger: Driver<Void>
        let toProfileTrigger: Driver<Void>
        let searchTrigger: Driver<Void>
        let cancelSearchTrigger: Driver<Void>
        let searchText: Driver<String>
        let selectAllTrigger: Driver<Void>
        let organizeTrigger: Driver<Void>
        let tableViewDidScroll: Driver<Void>
        let actionViewDismissed: Driver<Void>
        let cancelTrigger: Driver<Void>
        let itemSelected: Driver<Item>
        let deleteTrigger: Driver<Void>
    }

    struct Output {
        let embeddedLoading: Driver<Bool>
        let embeddedLoadingView: Driver<Bool>
        let refreshLoading: Driver<Bool>
        let enableDelete: Driver<Bool>
        let isSelectingAll: Driver<Bool>
        let enableSearch: Driver<Bool>
        let items: Driver<[Item]>
        let disableActions: Driver<Bool>
        let title: Driver<String>
        let hideTableView: Driver<Bool>
        let isEmpty: Driver<Bool>
        let emptyMessage: Driver<String>
        let errorMessage: Driver<String>
        let enableOrganize: Driver<Bool>
        let showActionView: Driver<Bool>
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
            input.cancelTrigger.map { false },
            input.refreshTrigger.map { false },
            input.viewWillDisappear.map { false },
            onDeleteNotes.map { false })
            .startWith(false)
            .distinctUntilChanged()

        let onToggleItemIsSelected = input.itemSelected
            .withLatestFrom(isSelectingAll, resultSelector: getItemForToggleIsSelected)
            .compactMap { $0 }
            .withLatestFrom(items.asDriver(), resultSelector: toggleItemIsSelected)
            .do(onNext: items.accept)
            .mapToVoid()

        let toEditNote = input.itemSelected
            .withLatestFrom(isSelectingAll, resultSelector: getNoteForNavigating)
            .compactMap { $0 }
            .map(UpdateNoteViewModel.NoteViewModel.init)
            .do(onNext: navigator.toEditNote)
            .mapToVoid()

        let onUncheckedAllItems = isSelectingAll
            .skip(1)
            .filter { !$0 }
            .withLatestFrom(items.asDriver())
            .map(uncheckedAllItems)
            .do(onNext: items.accept)
            .mapToVoid()

        let enableSearch = Driver.merge(
            input.searchTrigger.map { true },
            input.cancelSearchTrigger.map { false })
            .distinctUntilChanged()

        let currentItems = Driver.merge(
            fetchedNotes,
            isSelectingAll.filter { $0 }.delay(.milliseconds(250)).mapToVoid(),
            onUncheckedAllItems.delay(.milliseconds(250)),
            onToggleItemIsSelected,
            errorTracker.mapToVoid(),
            input.cancelSearchTrigger)
            .withLatestFrom(items.asDriver())

        let searchedItems = input.searchText
            .withLatestFrom(items.asDriver(), resultSelector: getSearchedItems)

        let outputItems = Driver.merge(currentItems, searchedItems)

        let disableActions = Driver.merge(
            embeddedLoading,
            refreshLoading,
            enableSearch,
            items.asDriver().map { $0.isEmpty })

        let title = Driver.just("Notes")

        let hideTableView = items.asDriver().map { $0.isEmpty }

        let isEmpty = outputItems
            .withLatestFrom(enableSearch) { $1 ? false : $0.isEmpty }
            .skip(1)

        let emptyMessage = isEmpty.map { $0 ? "Empty Notes" : "" }

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        let enableOrganize = Driver.merge(
            input.organizeTrigger.map { false },
            input.actionViewDismissed.map { true },
            input.cancelTrigger.map { true })

        let showActionView = Driver.merge(
            input.organizeTrigger.map { true },
            input.tableViewDidScroll.map { false })

        let onAction = Driver.merge(toLogin, toProfile, toAddNote, toEditNote, onDeleteNotes)

        return Output(
            embeddedLoading: embeddedLoading,
            embeddedLoadingView: embeddedLoadingView,
            refreshLoading: refreshLoading,
            enableDelete: enableDelete,
            isSelectingAll: isSelectingAll,
            enableSearch: enableSearch,
            items: outputItems,
            disableActions: disableActions,
            title: title,
            hideTableView: hideTableView,
            isEmpty: isEmpty,
            emptyMessage: emptyMessage,
            errorMessage: errorMessage,
            enableOrganize: enableOrganize,
            showActionView: showActionView,
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

    func getNoteForNavigating(item: Item, isSelectingAll: Bool) -> Note? {
        return !isSelectingAll ? item.note : nil
    }

    func getItemForToggleIsSelected(item: Item, isSelectingAll: Bool) -> Item? {
        return isSelectingAll ? item : nil
    }

    func toggleItemIsSelected(_ item: Item, from items: [Item]) -> [Item] {
        return handleItemSelection(item: item, isSelected: !item.isSelected, from: items)
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
        return items.compactMap { item in
            item.updated { $0.isSelected = false }
        }
    }

    func getSearchedItems(searchText: String, items: [Item]) -> [Item] {
        return searchText.isEmpty ? items : items.search(with: searchText)
    }
}

private extension Sequence where Element == HomeViewModel.Item {
    func selectedNotes() -> [Note] {
        return compactMap { $0.isSelected ? $0.note : nil }
    }

    func search(with text: String) -> [HomeViewModel.Item] {
        return filter { $0.note.title.lowercased().hasPrefix(text.lowercased()) }
    }
}
