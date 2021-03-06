import UIKit

extension UIApplication {
    var statusBarFrame: CGRect {
        return getWindow()?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }

    func getWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
    }

    func getTopViewController(
        base: UIViewController? = shared.getWindow()?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
