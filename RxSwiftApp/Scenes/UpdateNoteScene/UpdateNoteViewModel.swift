import RxSwift
import RxCocoa

struct UpdateNoteViewModel: ViewModelType {
    enum Kind {
        case add
        case edit(Note)
    }

    struct Input {
        let viewDidLoad: Driver<Void>
        let noteTitle: Driver<String>
        let noteDetails: Driver<String>
        let updateTrigger: Driver<Void>
        let deleteTrigger: Driver<Void>
    }

    struct Output {
        let title: Driver<String>
        let noteTitle: Driver<String>
        let noteDetails: Driver<String>
        let updateButtonTitle: Driver<String>
        let hideDeleteButton: Driver<Bool>
        let noteTitleIsEmpty: Driver<Bool>
        let noteDetailsIsEmpty: Driver<Bool>
        let showToast: Driver<String>
        let onAction: Driver<Void>
        let embeddedIndicator: Driver<Bool>
        let errorMessage: Driver<String>
    }

    private let kind: Kind
    private let usecase: UpdateNoteUsecase
    private let navigator: UpdateNoteNavigator

    init(kind: Kind, usecase: UpdateNoteUsecase, navigator: UpdateNoteNavigator) {
        self.kind = kind
        self.usecase = usecase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let kind = BehaviorRelay(value: self.kind)
        let note = BehaviorRelay(value: getNoteFromKind(kind.value))
        let indicator = ActivityIndicator()
        let errorTracker = ErrorTracker()

        let title = kind.asDriver().map { $0.title }

        let noteTrigger = input.viewDidLoad.withLatestFrom(note.asDriver())

        let noteTitle = noteTrigger.map { $0.title }

        let noteDetails = noteTrigger.map { $0.details }

        let updateButtonTitle = kind.asDriver().map { $0.updateButtonTitle }

        let hideDeleteButton = kind.asDriver().map { !$0.isEdit }

        let checkFieldsIsEmpty = input.updateTrigger.withLatestFrom(note.asDriver())

        let noteTitleIsEmpty = checkFieldsIsEmpty.map { $0.title.isEmpty }

        let noteDetailsIsEmpty = checkFieldsIsEmpty.map { $0.details.isEmpty }

        let validForRequest = Driver.combineLatest(noteTitleIsEmpty, noteDetailsIsEmpty)
            .map { !$0 && !$1 }

        let updatedNoteTitle = input.noteTitle
            .skip(1)
            .withLatestFrom(note.asDriver(), resultSelector: updateNoteTitle)
            .do(onNext: note.accept)
            .mapToVoid()

        let updatedNoteDetails = input.noteDetails
            .skip(1)
            .withLatestFrom(note.asDriver(), resultSelector: updateNoteDetails)
            .do(onNext: note.accept)
            .mapToVoid()

        let updatedNote = input.updateTrigger
            .withLatestFrom(validForRequest)
            .filter { $0 }
            .withLatestFrom(note.asDriver())
            .map { ($0, kind.value, indicator, errorTracker) }
            .flatMapLatest(updateNote)

        let addedNote = updatedNote
            .withLatestFrom(kind.asDriver())
            .filter { !$0.isEdit }
            .mapToVoid()

        let editedNote = updatedNote
            .withLatestFrom(kind.asDriver())
            .filter { $0.isEdit }
            .mapToVoid()

        let deletedNote = input.deleteTrigger
            .withLatestFrom(note.asDriver())
            .map { ($0, indicator, errorTracker) }
            .flatMapLatest(deleteNote)

        let emptyFieldsMessage = validForRequest
            .filter { !$0 }
            .map { _ in "Title and details fields can not be empty" }

        let showToast = Driver.merge(
            addedNote.map { "Added Note" },
            deletedNote.map { "Deleted Note" },
            emptyFieldsMessage,
            editedNote.map { "Edited Note" })

        let toHome = Driver.merge(addedNote, deletedNote).do(onNext: navigator.toHome)

        let onAction = Driver.merge(updatedNoteTitle, updatedNoteDetails, toHome)

        let embeddedIndicator = indicator.asDriver()

        let errorMessage = errorTracker.asDriver().map { $0.localizedDescription }

        return Output(
            title: title,
            noteTitle: noteTitle,
            noteDetails: noteDetails,
            updateButtonTitle: updateButtonTitle,
            hideDeleteButton: hideDeleteButton,
            noteTitleIsEmpty: noteTitleIsEmpty,
            noteDetailsIsEmpty: noteDetailsIsEmpty,
            showToast: showToast,
            onAction: onAction,
            embeddedIndicator: embeddedIndicator,
            errorMessage: errorMessage)
    }
}

private extension UpdateNoteViewModel.Kind {
    var title: String {
        switch self {
        case .add: return "Add Note"
        case .edit: return "Edit Note"
        }
    }

    var updateButtonTitle: String {
        switch self {
        case .add: return "Add"
        case .edit: return "Edit"
        }
    }

    var isEdit: Bool {
        switch self {
        case .add: return false
        case .edit: return true
        }
    }
}

private extension UpdateNoteViewModel {
    func updateNote(
        _ note: Note,
        kind: Kind,
        indicator: ActivityIndicator,
        errorTracker: ErrorTracker
    ) -> Driver<Void> {
        let request: Single<Void> = {
            switch kind {
            case .add: return usecase.addNote(note)
            case .edit: return usecase.updateNote(note)
            }
        }()
        return request
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func deleteNote(
        _ note: Note,
        indicator: ActivityIndicator,
        errorTracker: ErrorTracker
    ) -> Driver<Void> {
        return usecase.deleteNote(note)
            .trackActivity(indicator)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }

    func getNoteFromKind(_ kind: Kind) -> Note {
        switch kind {
        case .add: return Note()
        case .edit(let note): return note
        }
    }

    func updateNoteTitle(_ title: String, for note: Note) -> Note {
        return note.updated { $0.title = title }
    }

    func updateNoteDetails(_ details: String, for note: Note) -> Note {
        return note.updated { $0.details = details }
    }
}
