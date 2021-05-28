public struct Note: MutableType {
    public let id: String?
    public var title: String
    public var details: String

    public init() {
        id = nil
        title = ""
        details = ""
    }

    public init(id: String?, title: String, details: String) {
        self.id = id
        self.title = title
        self.details = details
    }

    public var data: [String: Any] {
        return [
            "title": title,
            "details": details,
            "timestamp": Date().timeIntervalSince1970,
        ]
    }
}
