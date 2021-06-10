import UIKit

extension UIColor {
  func toImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { rendererContext in
      setFill()
      rendererContext.fill(CGRect(origin: .zero, size: size))
    }
  }
}
