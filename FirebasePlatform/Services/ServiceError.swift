import Foundation
import Domain

enum ServiceError: ErrorType {
    case somethingWentWrong
    case userNotFound
    case userNotSync
    case noteNotFound
}

extension ServiceError {
    var forceSignOut: Bool {
        switch self {
        case .userNotFound, .userNotSync: return true
        default: return false
        }
    }
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
