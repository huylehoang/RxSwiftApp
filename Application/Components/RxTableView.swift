import UIKit

/// Use `RxTableView` to suppress the `AutoLayout` warning when bind `dataSource` early.
class RxTableView: UITableView {
  override func layoutSubviews() {
    guard nil != window else { return }
    super.layoutSubviews()
  }

  override func layoutIfNeeded() {
    guard nil != window else { return }
    super.layoutIfNeeded()
  }
}
