public protocol MutableType {
    func updated(by change: (inout Self) -> Void) -> Self
}

public extension MutableType {
    func updated(by change: (inout Self) -> Void) -> Self {
        var object = self
        change(&object)
        return object
    }
}
