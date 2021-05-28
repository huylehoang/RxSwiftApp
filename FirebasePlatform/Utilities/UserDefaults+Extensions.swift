import RxSwift
import Domain

extension UserDefaults {
    enum Key: ErrorType, CaseIterable {
        case userPassword
    }

    static func setValue(_ value: Any, forKey key: Key) {
        standard.setValue(value, forKey: key.description)
        standard.synchronize()
    }

    static func removeValue(forKey key: Key) {
        standard.removeObject(forKey: key.description)
        standard.synchronize()
    }

    static func removeAllValues() {
        Key.allCases.forEach(removeValue)
        standard.synchronize()
    }

    static func getStringValue(forKey key: Key) -> Single<String> {
        return .create { single in
            guard let value = standard.string(forKey: key.description) else {
                single(.failure(key))
                return Disposables.create()
            }
            single(.success(value))
            return Disposables.create()
        }
    }
}

extension UserDefaults.Key: LocalizedError, CustomStringConvertible {
    var description: String {
        switch self {
        case .userPassword: return "userPassword"
        }
    }

    var errorDescription: String? {
        switch self {
        case .userPassword: return "Missing sensitive data.\nPlease try to sign in again."
        }
    }
}

extension UserDefaults.Key {
    var forceSignOut: Bool {
        return self == .userPassword
    }
}