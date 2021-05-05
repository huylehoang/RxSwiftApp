import UIKit

extension UIApplication {
  var topViewController: UIViewController? {
    guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
      return nil
    }
    var topViewController = keyWindow.rootViewController
    while let presentedViewController = topViewController?.presentedViewController {
        topViewController = presentedViewController
    }
    return topViewController
  }
}
