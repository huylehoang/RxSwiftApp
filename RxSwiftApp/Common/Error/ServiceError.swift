import Foundation

enum ServiceError: Error {
    case somethingWentWrong
    case userNotFound
    case noteNotFound
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .somethingWentWrong: return "Something went wrong"
        case .userNotFound: return "User not found"
        case .noteNotFound: return "Note not found"
        }
    }
}
