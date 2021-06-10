import UIKit
import RxSwift

class RxTableViewCell: UITableViewCell {
    private(set) var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }
}
