import RxSwift
import RxCocoa

enum TextValidator {
    enum Kind {
        case name
        case email
        case password
    }

    static func validate(_ kind: Kind, for source: Driver<String>) -> Driver<String> {
        return source.map { onValidate(kind, forText: $0) }.distinctUntilChanged()
    }

    private static func onValidate(_ kind: Kind, forText text: String) -> String {
        guard !text.isEmpty else { return "" }
        let predicate = NSPredicate(format: "SELF MATCHES %@", kind.regEx)
        let evaluate = predicate.evaluate(with: text)
        return evaluate ? "" : kind.error
    }
}

private extension TextValidator.Kind {
    var regEx: String {
        switch self {
        case .name:
            return "\\w{7,18}"
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case .password:
            return "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        }
    }

    var error: String {
        switch self {
        case .name:
            return "7 - 18 characters without special characters"
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
