import Domain

public protocol HomeNavigator: NavigatorType {
    func toLogin()
    func toUser()
    func toAddNote()
    func toEditNote(_ note: UpdateNoteViewModel.NoteViewModel)
}
