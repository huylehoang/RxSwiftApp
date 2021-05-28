import RxSwift
import RxCocoa
import Domain

public struct UpdateNoteViewModel: ViewModelType {
    public enum Kind {
        case add
        case edit(NoteViewModel)
    }

    public struct NoteViewModel {
        let note: Note
    }

    struct Input {
        let viewDidLoad: Driver<Void>
        let noteTitle: Driver<String>
        let noteDetails: Driver<String>
        let endEditing: Driver<Void>
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

    let kind: Kind
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

        let trimming = Driver.merge(input.endEditing, input.updateTrigger)
            .withLatestFrom(note.asDriver())
            .map(trimmingFields)
            .do(onNext: note.accept)

        let viewDidLoad = input.viewDidLoad.withLatestFrom(note.asDriver())

        let noteTrigger = Driver.merge(viewDidLoad, trimming)

        let noteTitle = noteTrigger.map { $0.title }

        let noteDetails = noteTrigger.map { $0.details }

        let updateButtonTitle = kind.asDriver().map { $0.updateButtonTitle }

        let hideDeleteButton = kind.asDriver().map { !$0.isEdit }

        let checkFieldsIsEmpty = input.updateTrigger.withLatestFrom(note.asDriver())

        let noteTitleIsEmpty = checkFieldsIsEmpty.map { $0.title.isEmpty }

        let noteDetailsIsEmpty = checkFieldsIsEmpty.map { $0.details.isEmpty }

        let fieldsIsEmpty = Driver.combineLatest(noteTitleIsEmpty, noteDetailsIsEmpty)

        let fieldsNotEmpty = fieldsIsEmpty.map { !$0 && !$1 }

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
            .withLatestFrom(fieldsNotEmpty)
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

        let fieldsErrorToast = fieldsIsEmpty
            .compactMap { (titleIsEmpty, detailsIsEmpty) -> String? in
                switch (titleIsEmpty, detailsIsEmpty) {
                case (true, false): return "Title can not be empty"
                case (false, true): return "Details can not be empty"
                case (true, true): return "Title and details can not be empty"
                default: return nil
                }
            }

        let showToast = Driver.merge(
            addedNote.map { "Added Note" },
            deletedNote.map { "Deleted Note" },
            fieldsErrorToast,
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
        case .edit(let noteViewModel): return noteViewModel.note
        }
    }

    func updateNoteTitle(_ title: String, for note: Note) -> Note {
        return note.updated { $0.title = title }
    }

    func updateNoteDetails(_ details: String, for note: Note) -> Note {
        return note.updated { $0.details = details }
    }

    func trimmingFields(for note: Note) -> Note {
        return note.updated {
            $0.title = $0.title.trimmingWhitespacesAndNewlines()
            $0.details = $0.details.trimmingWhitespacesAndNewlines()
        }
    }
}
