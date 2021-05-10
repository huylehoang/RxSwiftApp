import RxSwift

extension UserDefaults {
    enum Key: String, CaseIterable {
        case userPassword
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

    static func getStringValue(forKey key: Key) -> Observable<String> {
        return Observable.just(standard.string(forKey: key.rawValue)).compactMap { $0 }
    }
}
