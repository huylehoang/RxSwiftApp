import RxSwift
import Domain

extension UserDefaults {
    enum Key: String, CaseIterable {
        case userPassword
    }

    enum Error: ErrorType {
        case userPasswordNotFound
    }

    static func setValue(_ value: Any, forKey key: Key) {
        standard.setValue(value, forKey: key.rawValue)
        standard.synchronize()
    }

    static func removeValue(forKey key: Key) {
        standard.removeObject(forKey: key.rawValue)
        standard.synchronize()
    }

    static func removeAllValues() {
        Key.allCases.forEach(removeValue)
        standard.synchronize()
    }

    static func getStringValue(forKey key: Key) -> Single<String> {
        return .create { single in
            guard let value = standard.string(forKey: key.rawValue) else {
                single(.failure(key.error))
                return Disposables.create()
            }
            single(.success(value))
            return Disposables.create()
        }
    }
}

extension UserDefaults.Key {
    var error: UserDefaults.Error {
        switch self {
        case .userPassword: return .userPasswordNotFound
        }
    }
}

extension UserDefaults.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userPasswordNotFound: return "Missing sensitive data.\nPlease try to sign in again."
        }
    }
}

extension UserDefaults.Error {
    var forceSignOut: Bool {
        return self == .userPasswordNotFound
    }
}
