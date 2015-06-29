//
//  SwipeTableViewCell.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit
import Swift

protocol SwipeTableViewCellDelegate {
  func startSwiping(cell: SwipeTableViewCell)
  func swiping(cell: SwipeTableViewCell, percentage: CGFloat)
  func endSwiping(cell: SwipeTableViewCell)
}

class SwipeTableViewCell : UITableViewCell {
  
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
  
  var isExited: Bool = false
  var dragging: Bool = false
  var trigger: CGFloat = Defaults.Trigger
  var animationDuration: CGFloat = Defaults.AnimationDuration
  var defaultColor = UIColor.whiteColor()
  var recognizer: UIPanGestureRecognizer?
  var screenshotView: UIView?
  var colorView: UIView?
  var slidingView: UIView?
  var activeView: UIView?
  var views = [UIView?](count: 2, repeatedValue: nil)
  var colors = [UIColor?](count: 2, repeatedValue: nil)
  var blocks = [CompletionBlock?](count: 2, repeatedValue: nil)
  var delegate: SwipeTableViewCellDelegate?
  var options: TransformOptions = .None

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    recognizer = UIPanGestureRecognizer()
    recognizer?.cancelsTouchesInView = true
    recognizer?.maximumNumberOfTouches = 1;
    recognizer?.addTarget(self, action: "handlePan:")
    addGestureRecognizer(recognizer!);
    
    initDefaults();
  }
  
  func initDefaults() {
    isExited = false
    dragging = false
    trigger = Defaults.Trigger
    animationDuration = Defaults.AnimationDuration
    defaultColor = UIColor.whiteColor()
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
    if screenshotView != nil {
      return
    }
    
    // If the content view background is transparent we get the background color.
//    let contentViewBackgroundClear = contentView.backgroundColor == nil
//    if contentViewBackgroundClear {
//      contentView.backgroundColor = backgroundColor!.isEqual(UIColor.clearColor()) ? UIColor.whiteColor() : backgroundColor
//    }
    
    let screenshotImage = image(view: self)
    
//    if contentViewBackgroundClear {
//      contentView.backgroundColor = nil
//    }
    
    colorView = UIView(frame: bounds)
    colorView!.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
    colorView!.backgroundColor = defaultColor ?? UIColor.clearColor()
    addSubview(colorView!)
    
    slidingView = UIView()
    slidingView!.contentMode = UIViewContentMode.Center
    colorView!.addSubview(slidingView!)
    
    screenshotView = UIImageView(image: screenshotImage)
    addSubview(screenshotView!)
  }
  
  func uninstallSwipingView() {
    if screenshotView == nil {
      return
    }

    slidingView!.removeFromSuperview()
    slidingView = nil
    
    colorView!.removeFromSuperview()
    colorView = nil
    
    screenshotView!.removeFromSuperview()
    screenshotView = nil
  }
  
  func image(view view: UIView) -> UIImage {
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
    view.layer.renderInContext(UIGraphicsGetCurrentContext())
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
  
  func addSlidingView(view: UIView) {
    if slidingView == nil {
      return;
    }
    
    for subView in slidingView!.subviews {
      subView.removeFromSuperview()
    }
    
    slidingView!.addSubview(view)
  }
  
  func setSwipeGesture(direction direction: Direction, view: UIView, color: UIColor, options: TransformOptions, completion: CompletionBlock) {
    self.options = options
    views[direction.hashValue] = view
    colors[direction.hashValue] = color
    blocks[direction.hashValue] = completion
  }
  
  func handlePan(recognizer: UIPanGestureRecognizer) {
    if isExited {
      return
    }
  
    let state = recognizer.state
    var currentX: CGFloat = 0
    if screenshotView != nil {
      currentX = screenshotView!.frame.origin.x
    }
    let percent = percentage(offset: currentX, width: bounds.width)
    let translationX = recognizer.translationInView(self).x
    let direction = (currentX + translationX) > 0 ? Direction.Right : Direction.Left
    
    switch (state) {
    case UIGestureRecognizerState.Began:
      setupSwipingView()
      delegate?.startSwiping(self)
      dragging = true
    case UIGestureRecognizerState.Changed:
      var frame = screenshotView!.frame
      if views[direction.hashValue] == nil {
        frame.origin.x = 0 // Use logirithmic scale
      } else {
        frame.origin.x = frame.origin.x + translationX
      }
      screenshotView!.frame = frame
      animateSwipe(direction, percentage: percent)
      recognizer.setTranslation(CGPointMake(0, 0), inView: self)
    
      delegate?.swiping(self, percentage: percent)
      break;
    case UIGestureRecognizerState.Cancelled, UIGestureRecognizerState.Ended:
      let velocity = recognizer.velocityInView(self)
      dragging = false
      activeView = views[direction.hashValue]
      
      if abs(percent) > trigger {
        finish(duration: animationDuration(velocity: velocity), direction: direction)
      } else {
        reset()
      }
      
      delegate?.endSwiping(self)
    default: ()
    }
  }
  
  static func offset(percentage percentage: CGFloat, width: CGFloat) -> CGFloat {
    var offset = percentage * width
    
    if offset < -width {
      offset = -width
    } else if offset > width {
      offset = width
    }
    
    return offset
  }
  
  func percentage(offset offset: CGFloat, width: CGFloat) -> CGFloat {
    var percentage = offset / width
    
    if percentage < -1.0 {
      percentage = -1.0
    } else if percentage > 1.0 {
      percentage = 1.0
    }
    
    return percentage
  }
  
  func animationDuration(velocity velocity: CGPoint) -> CGFloat {
    let width = bounds.width
    var horizontalVelocity = velocity.x
    
    if horizontalVelocity < -width {
      horizontalVelocity = -width
    } else if (horizontalVelocity > width) {
      horizontalVelocity = width
    }
    
    return Defaults.DurationHighLimit + Defaults.DurationLowLimit - abs(((horizontalVelocity / width) * Defaults.AnimationDurationDiff));
  }
  
  func rotation(percentage percentage: CGFloat) -> CGFloat {
    var rotation: CGFloat = 0.0
    if percentage >= 0 && percentage < trigger {
      rotation = CGFloat(M_PI) * percentage / trigger + CGFloat(M_PI)
    }
    return rotation
  }
  
  func scale(percentage percentage: CGFloat) -> CGFloat {
    return min(abs(percentage / (Defaults.ScaleRate * trigger)), 1)
  }
  
  func animateSwipe(direction: Direction, percentage: CGFloat) {
    if let view = views[direction.hashValue] {
      if options.contains(.Alpha) {
        slidingView!.alpha = min(abs(percentage / (Defaults.AlphaRate * trigger)), 1)
      }
      var transform = CGAffineTransformIdentity
      if options.contains(.Scale) {
        let scalePercentage = scale(percentage: percentage)
        transform = CGAffineTransformScale(transform, scalePercentage, scalePercentage)
      }
      if options.contains(.Rotate) {
        transform = CGAffineTransformRotate(transform, rotation(percentage: percentage))
      }
      view.transform = transform
      addSlidingView(view)
      slideView(direction: direction, percentage: percentage, view: view)
    }
    
    if let color = colors[direction.hashValue] {
      colorView!.backgroundColor = color
    }
  }
  
  func slideView(direction direction: Direction, percentage: CGFloat, view: UIView?) {
    if view == nil {
      return
    }
    
    var position = CGPointMake(0, 0)
    position.y = bounds.height / 2.0
    position.x = SwipeTableViewCell.offset(percentage: percentage - 0.05, width: bounds.width)
    let activeViewSize = view!.bounds.size;
    let activeViewFrame = CGRectMake(position.x - activeViewSize.width,
                                     position.y - activeViewSize.height / 2.0,
                                     activeViewSize.width,
                                     activeViewSize.height)
    
    slidingView!.frame = CGRectIntegral(activeViewFrame)
  }
  
  func finish(duration duration: CGFloat, direction: Direction) {
    isExited = true
    var originX: CGFloat = bounds.width
    var percentage: CGFloat = 1
    if direction == Direction.Left {
      originX = -bounds.width
      percentage = -1
    }
    
    if let color = colors[direction.hashValue] {
      colorView!.backgroundColor = color
    }
  
    UIView.animateWithDuration(NSTimeInterval(duration),
      delay: NSTimeInterval(0),
      options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.AllowUserInteraction],
      animations: {
        var frame = self.screenshotView!.frame
        frame.origin.x = originX
        self.screenshotView!.frame = frame
        self.slidingView!.alpha = 0
        self.slideView(direction: direction, percentage: percentage, view: self.activeView)
      },
      completion: { (finished: Bool) in
        self.blocks[direction.hashValue]!(self)
      })
  }
  
  func reset() {
    UIView.animateWithDuration(NSTimeInterval(animationDuration),
      delay: NSTimeInterval(0),
      usingSpringWithDamping: Defaults.Damping,
      initialSpringVelocity: Defaults.Velocity,
      options: UIViewAnimationOptions.CurveEaseOut,
      animations: {
        if self.activeView != nil {
          var frame = self.screenshotView!.frame
          frame.origin.x = 0
          self.screenshotView!.frame = frame
          self.colorView!.backgroundColor = self.defaultColor
          self.activeView!.transform = CGAffineTransformMakeRotation(self.rotation(percentage: 0))
          self.slidingView!.alpha = 0
          self.slideView(direction: Direction.Center, percentage: 0, view: self.activeView)
        }
      },
      completion: { (finished: Bool) in
        self.isExited = false
        self.uninstallSwipingView()
      })
  }
}
