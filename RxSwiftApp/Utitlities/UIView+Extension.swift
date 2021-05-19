import UIKit

extension UIView {
    private static var shadowLayersContext = 0
    private var shadowLayers: NSMutableArray {
      guard let shadowLayers = objc_getAssociatedObject(
        self,
        &UIView.shadowLayersContext) as? NSMutableArray
      else {
        let shadowLayers = NSMutableArray()
        objc_setAssociatedObject(
          self,
          &UIView.shadowLayersContext,
          shadowLayers,
          .OBJC_ASSOCIATION_RETAIN)
        return shadowLayers
      }
      return shadowLayers
    }

    /// Removes all shadow effects added by using the `applyXXXShadow()` methods.
    func removeShadowEffect() {
      let shadowLayers = self.shadowLayers
      for layer in shadowLayers {
        let shadowLayer = layer as? CAShapeLayer
        shadowLayer?.removeFromSuperlayer()
      }
      shadowLayers.removeAllObjects()
    }

    func applySubtleShadow() {
      // Box-shadow: 0px 0px 16px rgba(0, 0, 0, 0.08), 0px 0px 4px rgba(0, 0, 0, 0.05);
        let color = UIColor.black
      let layer1 = CAShapeLayer()
      layer1.cornerRadius = layer.cornerRadius
      layer1.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 16,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.08,
        bounds: bounds)

      let layer2 = CAShapeLayer()
      layer2.cornerRadius = layer.cornerRadius
      layer2.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 4,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.05,
        bounds: bounds)

      removeShadowEffect()
      layer.insertSublayer(layer2, at: 0)
      layer.insertSublayer(layer1, at: 0)
      let shadowLayers = self.shadowLayers
      shadowLayers.add(layer1)
      shadowLayers.add(layer2)
    }

    /// Apply the `Medium Shadow` as described in Figma
    func applyMediumShadow() {
      // Box-shadow: 0px 0px 16px rgba(0, 0, 0, 0.2), 0px 0px 4px rgba(0, 0, 0, 0.1);
        let color = UIColor.black
      let layer1 = CAShapeLayer()
      layer1.cornerRadius = layer.cornerRadius
      layer1.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 16,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.2,
        bounds: bounds)

      let layer2 = CAShapeLayer()
      layer2.cornerRadius = layer.cornerRadius
      layer2.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 4,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.1,
        bounds: bounds)

      removeShadowEffect()
      layer.insertSublayer(layer2, at: 0)
      layer.insertSublayer(layer1, at: 0)
      let shadowLayers = self.shadowLayers
      shadowLayers.add(layer1)
      shadowLayers.add(layer2)
    }

    func applyThickShadow() {
      // Box-shadow: 0px 0px 16px rgba(0, 0, 0, 0.3), 0px 0px 4px rgba(0, 0, 0, 0.5);
        let color = UIColor.black
      let layer1 = CAShapeLayer()
      layer1.cornerRadius = layer.cornerRadius
      layer1.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 16,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.3,
        bounds: bounds)

      let layer2 = CAShapeLayer()
      layer2.cornerRadius = layer.cornerRadius
      layer2.applyBoxShadow(
        offset: CGSize(width: 0, height: 0),
        blur: 4,
        spread: 0,
        shadowColor: color,
        fillColor: backgroundColor ?? .white,
        alpha: 0.5,
        bounds: bounds)

      removeShadowEffect()
      layer.insertSublayer(layer2, at: 0)
      layer.insertSublayer(layer1, at: 0)
      let shadowLayers = self.shadowLayers
      shadowLayers.add(layer1)
      shadowLayers.add(layer2)
    }
}

private extension CAShapeLayer {
  /// Create box shadow with specific bounds.
  func applyBoxShadow(
    offset: CGSize,
    blur: CGFloat,
    spread: CGFloat,
    shadowColor: UIColor,
    fillColor: UIColor,
    alpha: Float,
    bounds: CGRect) {
    path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    self.fillColor = fillColor.cgColor
    self.shadowColor = shadowColor.cgColor
    shadowOpacity = alpha
    shadowOffset = offset
    shadowRadius = blur / 2.0
    masksToBounds = false
    if spread == 0 {
      shadowPath = path
    } else {
      let rect = bounds.insetBy(dx: -spread, dy: -spread)
      shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
    }
  }
}
