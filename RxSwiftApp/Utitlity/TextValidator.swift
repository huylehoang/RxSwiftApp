import Foundation
import RxSwift
import RxCocoa

final class TextValidator {
    private let kind: Kind
    private let input: Driver<String>

    init(_ kind: Kind, input: Driver<String>) {
        self.kind = kind
        self.input = input
    }

    func validate() -> Driver<String> {
        return input.map(onValidate)
    }

    private func onValidate(_ text: String) -> String {
        guard !text.isEmpty else { return "" }
        let predicate = NSPredicate(format: "SELF MATCHES %@", kind.regEx)
        let evaluate = predicate.evaluate(with: text)
        return evaluate ? "" : kind.error
    }
}

extension TextValidator {
    enum Kind {
        case email
        case password
    }
}

private extension TextValidator.Kind {
    var regEx: String {
        switch self {
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case .password:
            return "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        }
    }

    var error: String {
        switch self {
        case .email:
            return "Please enter a valid email address"
        case .password:
            return """
                Password must contain one digit, one lowercase, one uppercase, \
                one special symbol and has at least 8 characters
                """
        }
    }
}
