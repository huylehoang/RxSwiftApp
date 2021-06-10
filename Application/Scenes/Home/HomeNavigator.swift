import Domain

public protocol HomeNavigator: NavigatorType {
    func toLogin()
    func toProfile()
    func toAddNote()
    func toEditNote(_ note: UpdateNoteViewModel.NoteViewModel)
}
