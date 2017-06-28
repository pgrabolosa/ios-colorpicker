import UIKit

/// A slider to pick colors. This is a control; you may listen for `.valueChanged`.
@IBDesignable public class ColorPicker : UIControl {
  
  private let gradientCornerRadius : CGFloat = 8
  private let cursorLayer = CAShapeLayer()
  private let gradientLayer = CAGradientLayer()
  
  private let desiredHeight : CGFloat = 16
  
  private let colors : [UIColor] = [.red, .yellow, .green, .cyan, .blue, .magenta, .red]
  
  /// This could be constructed from the colors array, but it is here detailed for performance.
  private let colorIntervals : [(UIColor, UIColor)] = [
    (.red, .yellow),
    (.yellow, .green),
    (.green, .cyan),
    (.cyan, .blue),
    (.blue, .magenta),
    (.magenta, .red)
  ]
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialSetup()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialSetup()
    self.value = aDecoder.decodeFloat(forKey: "value")
  }
  
  /// Initial configuration of the view
  private func initialSetup() {
    // background gradient
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)
    gradientLayer.colors = colors.map { $0.cgColor }
    gradientLayer.cornerRadius = gradientCornerRadius
    
    // cursor creation
    cursorLayer.fillColor = colors[0].cgColor
    cursorLayer.strokeColor = UIColor.white.cgColor
    cursorLayer.lineWidth = 3
    cursorLayer.masksToBounds = false
    cursorLayer.shadowColor = UIColor.black.cgColor
    cursorLayer.shadowOpacity = 0.4
    cursorLayer.shadowOffset = CGSize(width: 0, height: 0)
    
    // add subviews
    layer.addSublayer(gradientLayer)
    layer.addSublayer(cursorLayer)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    gradientLayer.frame = CGRect(
      x: 0,
      y: bounds.midY - desiredHeight / 2,
      width: bounds.width,
      height: desiredHeight
    )
    
    cursorLayer.path = UIBezierPath(ovalIn: CGRect(
      x: -desiredHeight/2,
      y: bounds.midY - desiredHeight / 2,
      width: desiredHeight,
      height: desiredHeight).insetBy(dx: -4, dy: -4)
    ).cgPath
  }
  
  /// The value is between 0.0 and 1.0 representing the hue of the picked color.
  @IBInspectable public var value : Float = 0.0 {
    didSet {
      catransaction(animating: animateValueChangeAnimation) {
        cursorLayer.transform = CATransform3DMakeTranslation(CGFloat(value) * bounds.width, 0, 0)
        cursorLayer.fillColor = self.color.cgColor
      }
      sendActions(for: .valueChanged)
    }
  }
  
  /// By default, setting the value will move the cursor; but when moving along with the user's touch we want to disable animations.
  private var animateValueChangeAnimation = false
  
  /// Instead of setting a value by picking a float between 0.0 and 1.0, this function sets the value from the hue of a color.
  ///
  /// - Parameter color: The color which hue should be used.
  public func setValue(from color: UIColor) {
    var hue : CGFloat = 0
    color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
    value = Float(hue)
  }
  
  /// The picked color based on the current `value`.
  public var color : UIColor {
    let intervalWidth = 1.0 / Float(colorIntervals.count)
    
    let intervalIndex = Int(value / intervalWidth)
    let (startColor, endColor) = colorIntervals[min(intervalIndex, colorIntervals.count-1)]
    
    let progression = max(0.0, min(1.0, Float(value.truncatingRemainder(dividingBy: intervalWidth) / intervalWidth)))
    
    let (r1,g1,b1) = startColor.rgbValues
    let (r2,g2,b2) = endColor.rgbValues
    
    return UIColor(colorLiteralRed: r1 + progression * (r2 - r1),
                   green: g1 + progression * (g2 - g1),
                   blue: b1 + progression * (b2 - b1),
                   alpha: 1)
  }
  
  /// Utility function to run a block disabling or enabling the default CA animations.
  ///
  /// - Parameters:
  ///   - animating: should the default animations be enabled?
  ///   - block: the code to run
  private func catransaction(animating: Bool, _ block: ()->Void) {
    if animating {
      block()
    } else {
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
      block()
      CATransaction.commit()
    }
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!.location(in: self)
    didTouch(location: touch, began: true)
  }
  
  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!.location(in: self)
    didTouch(location: touch)
  }
  
  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!.location(in: self)
    didTouch(location: touch)
  }
  
  private func didTouch(location: CGPoint, began: Bool = false) {
    animateValueChangeAnimation = began
    value = max(0, min(1, Float(location.x / self.bounds.width)))
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: 150, height: 16)
  }
}
