import Foundation

enum ServiceError: Error {
    case somethingWentWrong
    case userNotFound
    case userNotSync
    case noteNotFound
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .somethingWentWrong: return "Something went wrong"
        case .userNotFound: return "User not found"
        case .userNotSync: return "Syncing failed.\nPlease login again"
        case .noteNotFound: return "Note not found"
        }
    }
}
