import Foundation

public protocol ErrorType: Swift.Error {
    var forceSignOut: Bool { get }
}
