import Domain

public struct UsecaseProvider: Domain.UsecaseProvider {
    public init() {}

    public func makeLoginUsecase() -> Domain.LoginUsecase {
        return LoginUsecase(
            authService: DefaultAuthService(),
            profileService: DefaultProfileService())
    }

    public func makeHomeUsecase() -> Domain.HomeUsecase {
        return HomeUsecase(
            noteService: DefaultNoteService(),
            profileService: DefaultProfileService())
    }

    public func makeUpdateNoteUsecase() -> Domain.UpdateNoteUsecase {
        return UpdateNoteUsecase(service: DefaultNoteService())
    }

    public func makeProfileUsecase() -> Domain.ProfileUsecase {
        return ProfileUsecase(
            authService: DefaultAuthService(),
            profileService: DefaultProfileService(),
            noteService: DefaultNoteService())
    }
}
