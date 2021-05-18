import UIKit

typealias Constraint = NSLayoutConstraint

extension Constraint {
    static func activate(_ constraints: NSLayoutConstraint...) {
        activate(constraints)
    }

    func constant(_ constant: CGFloat) -> NSLayoutConstraint {
        return updated { $0.constant = constant }
    }

    func priority(_ priority: LayoutPriority) -> NSLayoutConstraint {
        return updated { priority.setPriority(for: $0) }
    }

    private func updated(by change: (NSLayoutConstraint) -> Void) -> NSLayoutConstraint {
        change(self)
        return self
    }
}

extension NSLayoutDimension {
    func equalTo(_ constant: CGFloat) -> NSLayoutConstraint {
        let constraint = self.constraint(equalToConstant: constant)
        return constraint
    }

    func greaterThanOrEqualTo(_ constant: CGFloat) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualToConstant: constant)
        return constraint
    }

    func lessThanOrEqualTo(_ constant: CGFloat) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualToConstant: constant)
        return constraint
    }

    func equalTo(_ anchor: NSLayoutDimension, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor, multiplier: multiplier)
        return constraint
    }

    func greaterThanEqualTo(
        _ anchor: NSLayoutDimension,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier)
        return constraint
    }

    func lessThanEqualTo(
        _ anchor: NSLayoutDimension,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier)
        return constraint
    }
}

extension NSLayoutAnchor {
    @objc func equalTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        return constraint
    }

    @objc func greaterThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor)
        return constraint
    }

    @objc func lessThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor)
        return constraint
    }
}

enum LayoutPriority {
    case required
    case defaultHigh
    case defaultLow
    case level(Float)
    case normal

    private var priority: UILayoutPriority? {
        switch self {
        case .required: return .required
        case .defaultHigh: return .defaultHigh
        case .defaultLow: return .defaultLow
        case .level(let level): return UILayoutPriority(level)
        case .normal: return nil
        }
    }

    fileprivate func setPriority(for constraint: NSLayoutConstraint) {
        guard let priority = priority else { return }
        constraint.priority = priority
    }
}

extension UIView {
    var leading: NSLayoutXAxisAnchor {
        return leadingAnchor
    }

    var trailing: NSLayoutXAxisAnchor {
        return trailingAnchor
    }

    var centerX: NSLayoutXAxisAnchor {
        return centerXAnchor
    }

    var top: NSLayoutYAxisAnchor {
        return topAnchor
    }

    var bottom: NSLayoutYAxisAnchor {
        return bottomAnchor
    }

    var centerY: NSLayoutYAxisAnchor {
        return centerYAnchor
    }

    var height: NSLayoutDimension {
        return heightAnchor
    }

    var width: NSLayoutDimension {
        return widthAnchor
    }
}

extension UILayoutGuide {
    var leading: NSLayoutXAxisAnchor {
        return leadingAnchor
    }

    var trailing: NSLayoutXAxisAnchor {
        return trailingAnchor
    }

    var centerX: NSLayoutXAxisAnchor {
        return centerXAnchor
    }

    var top: NSLayoutYAxisAnchor {
        return topAnchor
    }

    var bottom: NSLayoutYAxisAnchor {
        return bottomAnchor
    }

    var centerY: NSLayoutYAxisAnchor {
        return centerYAnchor
    }

    var height: NSLayoutDimension {
        return heightAnchor
    }

    var width: NSLayoutDimension {
        return widthAnchor
    }
}
