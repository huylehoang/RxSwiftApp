import UIKit

class BaseViewController: UIViewController {
    let contentView: UIView

    init() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.addSubview(contentView)
        let trailing = contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        trailing.priority = UILayoutPriority(rawValue: 999)
        let constraints = [
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailing,
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        hideNavigationBar(true)
    }
}

extension BaseViewController {
    func hideNavigationBar(_ hide: Bool, animated: Bool = false) {
        navigationController?.setNavigationBarHidden(hide, animated: animated)
    }
}
