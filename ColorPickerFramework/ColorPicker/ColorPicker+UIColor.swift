import UIKit

extension UIColor {
  var rgbValues : (Float, Float, Float) {
    var r : CGFloat = 0
    var g : CGFloat = 0
    var b : CGFloat = 0
    
    self.getRed(&r, green: &g, blue: &b, alpha: nil)
    
    return (Float(r), Float(g), Float(b))
  }
}
