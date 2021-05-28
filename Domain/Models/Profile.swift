public struct Profile: Equatable {
    public let id: String
    public let name: String?
    public let mail: String?

    public init(id: String, name: String?, mail: String?) {
        self.id = id
        self.name = name
        self.mail = mail
    }

    public var data: [String: Any] {
        var defaultData: [String: Any] = [
            "id": id,
            "timestamp": Date().timeIntervalSince1970,
        ]
        if let name = name {
            defaultData.updateValue(name, forKey: "name")
        }
        if let mail = mail {
            defaultData.updateValue(mail, forKey: "mail")
        }
        return defaultData
    }
}
