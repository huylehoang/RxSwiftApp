import Domain

extension HomeScene {
    struct CellViewModel: MutableType {
        let note: Note
        var isSelected = false

        init(note: Note) {
            self.note = note
        }
    }
}
