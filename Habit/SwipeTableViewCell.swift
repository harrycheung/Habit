//
//  SwipeTableViewCell.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc protocol SwipeTableViewCellDelegate {
  optional func startSwiping(cell: SwipeTableViewCell)
  optional func swiping(cell: SwipeTableViewCell, percentage: CGFloat)
  optional func endSwiping(cell: SwipeTableViewCell)
}

class SwipeTableViewCell: UITableViewCell {
  
  struct Defaults {
    static let Trigger: CGFloat           = 0.33 // Percentage limit to trigger the First action
    static let Damping: CGFloat           = 0.5  // Damping of the spring animation
    static let Velocity: CGFloat          = 0.5  // Velocity of the spring animation
    static let AnimationDuration: CGFloat = 0.75 // Duration of the animation
    static let DurationLowLimit: CGFloat  = 0.25 // Lowest duration when swiping the cell because we try to simulate velocity
    static let DurationHighLimit: CGFloat = 0.1  // Highest duration when swiping the cell because we try to simulate velocity
    static let AnimationDurationDiff: CGFloat = DurationHighLimit - DurationLowLimit
    static let AlphaRate: CGFloat         = 0.6  // When full alpha is achieved relative to trigger
    static let ScaleRate: CGFloat         = 0.6  // When full scale is achieved relative to trigger
    static let IconViewMargin: CGFloat    = 30
  }
  
  enum Direction {
    case Left, Right, Center
  }
  
  struct TransformOptions : OptionSetType {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let None = TransformOptions(rawValue: 0)
    static let Scale = TransformOptions(rawValue: 1)
    static let Rotate = TransformOptions(rawValue: 2)
    static let Alpha = TransformOptions(rawValue: 4)
  }
  
  typealias CompletionBlock = (SwipeTableViewCell) -> (Void)
  
  static var swipeCellCount = 0
  
  static var isSwiping: Bool {
    return swipeCellCount != 0
  }
  
  var active: Bool = false
  var dragging: Bool = false
  var swipable: Bool = true
  var currentOffset: CGFloat!
  var cantSwipeLabel: UIView?
  var trigger: CGFloat = Defaults.Trigger
  var animationDuration: CGFloat = Defaults.AnimationDuration
  var recognizer: UIPanGestureRecognizer!
  var screenshotView: UIView!
  var colorView: UIView!
  var slidingView: UIView!
  var activeView: UIView?
  var views = [UIView?](count: 2, repeatedValue: nil)
  var colors = [UIColor?](count: 2, repeatedValue: nil)
  var blocks = [CompletionBlock?](count: 2, repeatedValue: nil)
  var options = [TransformOptions](count: 2, repeatedValue: .None)
  var delegate: SwipeTableViewCellDelegate?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    recognizer = UIPanGestureRecognizer()
    recognizer.delegate = self
    recognizer.addTarget(self, action: #selector(SwipeTableViewCell.handlePan(_:)))
    addGestureRecognizer(recognizer)
    
    initDefaults();
  }
  
  func initDefaults() {
    active = false
    dragging = false
    currentOffset = 0
    trigger = Defaults.Trigger
    animationDuration = Defaults.AnimationDuration
    views[0...1] = [nil, nil]
    colors[0...1] = [nil, nil]
    blocks[0...1] = [nil, nil]
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    uninstallSwipingView()
    initDefaults()
  }
  
  func setupSwipingView() {
    uninstallSwipingView()
    if screenshotView != nil {
      return
    }
    
    active = true
    
    colorView = UIView(frame: bounds)
    addSubview(colorView)
    
    slidingView = UIView()
    slidingView.contentMode = UIViewContentMode.Center
    colorView.addSubview(slidingView)
    
    let screenshotImage = image(view: self)
    screenshotView = UIImageView(image: screenshotImage)
    addSubview(screenshotView)
    
    if cantSwipeLabel != nil {
      addSubview(cantSwipeLabel!)
      cantSwipeLabel!.translatesAutoresizingMaskIntoConstraints = false
      cantSwipeLabel!.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
      cantSwipeLabel!.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      bringSubviewToFront(cantSwipeLabel!)
    }
  }
  
  func uninstallSwipingView() {
    if screenshotView == nil {
      return
    }

    slidingView.removeFromSuperview()
    slidingView = nil
    
    colorView.removeFromSuperview()
    colorView = nil
    
    screenshotView.removeFromSuperview()
    screenshotView = nil
    
    cantSwipeLabel?.removeFromSuperview()
  }
  
  func image(view view: UIView) -> UIImage {
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
    view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
  
  func addSlidingView(view: UIView) {
    guard slidingView != nil else {
      return
    }
    
    for subView in slidingView.subviews {
      subView.removeFromSuperview()
    }
    
    slidingView.addSubview(view)
  }
  
  func setSwipeGesture(direction direction: Direction, view: UIView, color: UIColor,
    options transformOptions: TransformOptions, completion: CompletionBlock) {
    options[direction.hashValue] = transformOptions
    views[direction.hashValue] = view
    colors[direction.hashValue] = color
    blocks[direction.hashValue] = completion
  }
  
  override func gestureRecognizerShouldBegin(recognizer: UIGestureRecognizer) -> Bool {
    if recognizer is UIPanGestureRecognizer {
      let panRecognizer = recognizer as! UIPanGestureRecognizer
      let point = panRecognizer.velocityInView(self)
      if abs(point.x) > abs(point.y) {
        if (point.x < 0 && views[Direction.Left.hashValue] == nil) ||
          (point.x > 0 && views[Direction.Right.hashValue] == nil) {
          return false
        }
        return true
      }
    }
    return false
  }
  
  
  func handlePan(recognizer: UIPanGestureRecognizer) {
    if recognizer.state == UIGestureRecognizerState.Began {
      if !active {
        delegate?.startSwiping?(self)
        setupSwipingView()
        SwipeTableViewCell.swipeCellCount += 1
        cantSwipeLabel?.alpha = 0
      } else {
        currentOffset = (screenshotView.layer.presentationLayer() as! CALayer).frame.origin.x
        screenshotView.layer.removeAllAnimations()
        activeView!.layer.removeAllAnimations()
        slidingView.layer.removeAllAnimations()
      }
    }
    
    let newOffset = currentOffset + recognizer.translationInView(self).x
    var percent = percentage(offset: newOffset, width: bounds.width)
    let direction = percent > 0 ? Direction.Right : Direction.Left
    
    switch (recognizer.state) {
    case .Began, .Changed:
      dragging = true
      var frame = screenshotView.frame
      if views[direction.hashValue] == nil {
        frame.origin.x = 0
        percent = 0
      } else if swipable {
        frame.origin.x = newOffset
      } else {
        if abs(percent) > trigger / 2 {
          cantSwipeLabel?.alpha = (abs(percent) - trigger / 2) / 0.5
        }
        // Can't swipe to create elastic effect
        frame.origin.x = trigger * bounds.width * tanh(newOffset / 200)
        percent = percentage(offset: frame.origin.x, width: bounds.width)
      }
      screenshotView.frame = frame
      animateSwipe(direction, percentage: percent)
    
      delegate?.swiping?(self, percentage: percent)
    case .Cancelled, .Ended:
      let velocity = recognizer.velocityInView(self)
      dragging = false
      activeView = views[direction.hashValue]
      
      if swipable && abs(percent) > trigger {
        finish(duration: animationDuration(velocity: velocity), direction: direction)
      } else {
        reset()
      }
    default: ()
    }
  }
  
  private static func offset(percentage percentage: CGFloat, width: CGFloat) -> CGFloat {
    var offset = percentage * width
    
    if offset < 0 {
      offset = width + offset
    }
    
    if offset < -width {
      offset = -width
    } else if offset > width {
      offset = width
    }
    
    return offset
  }
  
  private func percentage(offset offset: CGFloat, width: CGFloat) -> CGFloat {
    var percentage = offset / width
    
    if percentage < -1.0 {
      percentage = -1.0
    } else if percentage > 1.0 {
      percentage = 1.0
    }
    
    return percentage
  }
  
  private func animationDuration(velocity velocity: CGPoint) -> CGFloat {
    let width = bounds.width
    var horizontalVelocity = velocity.x
    
    if horizontalVelocity < -width {
      horizontalVelocity = -width
    } else if (horizontalVelocity > width) {
      horizontalVelocity = width
    }
    
    return Defaults.DurationHighLimit + Defaults.DurationLowLimit - abs(((horizontalVelocity / width) * Defaults.AnimationDurationDiff));
  }
  
  private func rotation(percentage percentage: CGFloat) -> CGFloat {
    var rotation: CGFloat = 0.0
    if percentage > 0 && percentage < trigger {
      rotation = CGFloat(M_PI) * percentage / trigger + CGFloat(M_PI)
    } else if percentage < 0 && percentage > -trigger {
      rotation = CGFloat(M_PI) * (1 + percentage) / trigger
    } else if percentage == 0 {
      rotation = CGFloat(M_PI)
    }
    return rotation
  }
  
  private func scale(percentage percentage: CGFloat) -> CGFloat {
    return min(abs(percentage / (Defaults.ScaleRate * trigger)), 1)
  }
  
  private func animateSwipe(direction: Direction, percentage: CGFloat) {
    if let view = views[direction.hashValue] {
      if options[direction.hashValue].contains(.Alpha) {
        slidingView.alpha = min(abs(percentage / (Defaults.AlphaRate * trigger)), 1)
      }
      var transform = CGAffineTransformIdentity
      if options[direction.hashValue].contains(.Scale) {
        let scalePercentage = scale(percentage: abs(percentage))
        transform = CGAffineTransformScale(transform, scalePercentage, scalePercentage)
      }
      if options[direction.hashValue].contains(.Rotate) {
        transform = CGAffineTransformRotate(transform, rotation(percentage: percentage))
      }
      view.transform = transform
      addSlidingView(view)
      slideView(direction: direction, percentage: percentage, view: view)
    }
    
    if let color = colors[direction.hashValue] {
      colorView.backgroundColor = color
    }
  }
  
  private func slideView(direction direction: Direction, percentage: CGFloat, view: UIView!) {
    var position = CGPointMake(SwipeTableViewCell.offset(percentage: percentage, width: bounds.width),
                               bounds.height / 2.0)
    print("\(percentage) \(position.x)")
    switch direction {
    case .Right:
      position.x -= Defaults.IconViewMargin
    case .Left:
      position.x += Defaults.IconViewMargin
    default:
      position.x = 0
    }
    let activeViewSize = view.bounds.size
    let activeViewFrame = CGRectMake(position.x - activeViewSize.width / 2.0,
                                     position.y - activeViewSize.height / 2.0,
                                     activeViewSize.width,
                                     activeViewSize.height)
    slidingView.frame = CGRectIntegral(activeViewFrame)
  }
  
  private func finish(duration duration: CGFloat, direction: Direction) {
    removeGestureRecognizer(recognizer)
    
    var originX: CGFloat!
    var percentage: CGFloat!
    if direction == .Left {
      originX = -bounds.width
      percentage = -1
    } else {
      originX = bounds.width
      percentage = 1
    }
  
    UIView.animateWithDuration(NSTimeInterval(duration),
                               delay: NSTimeInterval(0),
                               options: [.CurveEaseOut],
                               animations: {
                                var frame = self.screenshotView.frame
                                frame.origin.x = originX
                                self.screenshotView.frame = frame
                                self.slideView(direction: direction, percentage: percentage, view: self.activeView)
    },
                               completion: { finished in
                                self.blocks[direction.hashValue]!(self)
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(self)
    })
  }
  
  private func reset() {
//    colorView.backgroundColor = UIColor.clearColor()
//    print(screenshotView.frame.origin.x)
//    if self.screenshotView.frame.origin.x < 0 {
//      let leftColorView = UIView(frame: CGRectMake(0, 0, frame.width / 2, frame.height))
//      leftColorView.backgroundColor = colors[Direction.Right.hashValue] ?? contentView.backgroundColor
//      colorView.addSubview(leftColorView)
//    } else {
//      let rightColorView = UIView(frame: CGRectMake(frame.width / 2, 0, frame.width / 2, frame.height))
//      rightColorView.backgroundColor = colors[Direction.Left.hashValue] ?? contentView.backgroundColor
//      colorView.addSubview(rightColorView)
//    }
    
    UIView.animateWithDuration(10, //NSTimeInterval(animationDuration * 3),
                               delay: NSTimeInterval(0),
                               usingSpringWithDamping: Defaults.Damping,
                               initialSpringVelocity: 0, //Defaults.Velocity,
                               options: [.CurveEaseOut, .AllowUserInteraction],
                               animations: {
                                if self.activeView != nil {
                                  var frame = self.screenshotView.frame
                                  let offset = frame.origin.x
                                  frame.origin.x = 0
                                  self.screenshotView.frame = frame
                                  self.activeView!.transform = CGAffineTransformMakeRotation(self.rotation(percentage: 0))
                                  self.slidingView.alpha = 0
                                  let direction = offset > 0 ? Direction.Right : Direction.Left
                                  print(direction)
                                  self.slideView(direction: direction, percentage: 0, view: self.activeView)
                                }
      },
                               completion: { finished in
                                guard !self.dragging else {
                                  return
                                }
                                
                                self.active = false
                                self.currentOffset = 0
                                self.uninstallSwipingView()
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(self)
    })
    
    // Hide not swipable text
    if !swipable {
      UIView.animateWithDuration(NSTimeInterval(animationDuration)) {
        self.cantSwipeLabel?.alpha = 0
      }
    }
  }
  
}
