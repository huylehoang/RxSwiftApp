protocol MutableType {
    func updated(by change: (inout Self) -> Void) -> Self
}

extension MutableType {
    func updated(by change: (inout Self) -> Void) -> Self {
        var object = self
        change(&object)
        return object
    }
}
