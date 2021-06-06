public protocol UsecaseProvider {
    func makeLoginUsecase() -> LoginUsecase
    func makeHomeUsecase() -> HomeUsecase
    func makeUpdateNoteUsecase() -> UpdateNoteUsecase
    func makeProfileUsecase() -> ProfileUsecase
}
