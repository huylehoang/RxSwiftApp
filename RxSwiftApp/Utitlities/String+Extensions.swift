import Foundation

extension String {
    func trimmingWhitespacesAndNewlines() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
