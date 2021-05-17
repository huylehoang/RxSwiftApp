import Foundation

enum SceneBuidlerError {
    case missingUsecaseNavigator
}

extension SceneBuidlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingUsecaseNavigator: return "Missing\nUsecase & Navigator"
        }
    }
}
