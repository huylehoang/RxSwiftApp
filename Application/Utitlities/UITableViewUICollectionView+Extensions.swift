import UIKit

import UIKit

protocol RegistrableCell {
    static var identifier: String { get }
}

extension RegistrableCell {
    static var identifier: String {
        String(describing: Self.self)
    }
}

extension UITableViewCell: RegistrableCell {}

extension UICollectionViewCell: RegistrableCell {}

extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath
    ) -> T {
        return dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath) as! T
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath
    ) -> T {
        return dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath) as! T
    }
}

