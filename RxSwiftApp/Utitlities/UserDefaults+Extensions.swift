import RxSwift

extension UserDefaults {
    enum Key: String, CaseIterable {
        case userPassword
    }

    static func setValue(_ value: Any, forKey key: Key) -> Observable<Void> {
        return .deferred {
            standard.setValue(value, forKey: key.rawValue)
            standard.synchronize()
            return .just(())
        }
    }

    static func removeValue(forKey key: Key) -> Observable<Void> {
        return .deferred {
            standard.removeObject(forKey: key.rawValue)
            standard.synchronize()
            return .just(())
        }
    }

    static func removeAllValues() -> Observable<Void> {
        return .deferred {
            Key.allCases.forEach { standard.removeObject(forKey: $0.rawValue) }
            standard.synchronize()
            return .just(())
        }
    }

    static func getStringValue(forKey key: Key) -> Observable<String> {
        return Observable.just(standard.string(forKey: key.rawValue)).compactMap { $0 }
    }
}
