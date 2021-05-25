import Foundation

extension Error {
    var forceSignOut: Bool {
        if let serviceError = self as? ServiceError  {
            return serviceError == .userNotFound || serviceError == .userNotSync
        } else if let userDefaultsError = self as? UserDefaults.Key {
            return userDefaultsError == .userPassword
        }
        return false
    }
}
