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
    static let IconViewMargin: CGFloat    = 16   // Margin from icon to sliding cell
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
  
  // Internal state
  private var recognizer: UIPanGestureRecognizer!
  private var active: Bool = false
  private var dragging: Bool = false
  private var currentOffset: CGFloat!
  private var trigger: CGFloat = Defaults.Trigger
  private var animationDuration: CGFloat = Defaults.AnimationDuration
  private var swipingView: UIView!
  private var swipingConstraint: NSLayoutConstraint!
  private var colorViews: [UIView]!
  
  // Options
  private var iconViews = [UIView?](count: 2, repeatedValue: nil)
  private var colors = [UIColor?](count: 2, repeatedValue: nil)
  private var blocks = [CompletionBlock?](count: 2, repeatedValue: nil)
  private var options = [TransformOptions](count: 2, repeatedValue: .None)
  
  var swipable: Bool = true
  var cantSwipeLabel: UIView?
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
    iconViews[0...1] = [nil, nil]
    colors[0...1] = [nil, nil]
    blocks[0...1] = [nil, nil]
    colorViews = []
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    if !colorViews.isEmpty {
      uninstallSwipingView()
    }
    initDefaults()
  }
  
  private func installSwipingView() {
    active = true
    
    swipingView = UIImageView(image: image(view: self))
    addSubview(swipingView)
    swipingView.translatesAutoresizingMaskIntoConstraints = false
    swipingView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    swipingConstraint = swipingView.leftAnchor.constraintEqualToAnchor(leftAnchor)
    swipingConstraint.active = true
    swipingView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
    swipingView.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
    
    if let iconView = iconViews[Direction.Left.hashValue] {
      let view = UIView()
      view.backgroundColor = colors[Direction.Left.hashValue]
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      view.leftAnchor.constraintEqualToAnchor(swipingView.rightAnchor).active = true
      view.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
      view.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
      colorViews.append(view)
      addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false
      iconView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      iconView.leftAnchor.constraintEqualToAnchor(swipingView.rightAnchor,
                                                  constant: Defaults.IconViewMargin).active = true
    }

    if let iconView = iconViews[Direction.Right.hashValue] {
      let view = UIView()
      view.backgroundColor = colors[Direction.Right.hashValue]
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      view.rightAnchor.constraintEqualToAnchor(swipingView.leftAnchor).active = true
      view.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
      view.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
      colorViews.append(view)
      addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false
      iconView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      iconView.rightAnchor.constraintEqualToAnchor(swipingView.leftAnchor,
                                                   constant: -Defaults.IconViewMargin).active = true
    }
    
    if let view = cantSwipeLabel {
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
      view.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      bringSubviewToFront(view)
    }
  }
  
  func uninstallSwipingView() {
    for view in iconViews {
      view?.removeFromSuperview()
    }
    for view in colorViews {
      view.removeFromSuperview()
    }
    colorViews = []
    swipingView.removeFromSuperview()
    cantSwipeLabel?.removeFromSuperview()
  }
  
  private func image(view view: UIView) -> UIImage {
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
    view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
  
  func setSwipeGesture(direction direction: Direction,
                       iconView: UIView,
                       color: UIColor,
                       options transformOptions: TransformOptions,
                       completion: CompletionBlock) {
    options[direction.hashValue] = transformOptions
    iconViews[direction.hashValue] = iconView
    colors[direction.hashValue] = color
    blocks[direction.hashValue] = completion
  }
  
  func canSwipe(direction: Direction) -> Bool {
    return iconViews[direction.hashValue] != nil
  }
  
  override func gestureRecognizerShouldBegin(recognizer: UIGestureRecognizer) -> Bool {
    if let panRecognizer = recognizer as? UIPanGestureRecognizer {
      let velicity = panRecognizer.velocityInView(self)
      if abs(velicity.x) > abs(velicity.y) {
        if (velicity.x < 0 && !canSwipe(.Left)) || (velicity.x > 0 && !canSwipe(.Right)) {
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
        installSwipingView()
        SwipeTableViewCell.swipeCellCount += 1
        cantSwipeLabel?.alpha = 0
      } else {
        currentOffset = (swipingView.layer.presentationLayer() as! CALayer).frame.origin.x
        swipingView.layer.removeAllAnimations()
        for view in iconViews {
          view?.layer.removeAllAnimations()
        }
        for view in colorViews {
          view.layer.removeAllAnimations()
        }
      }
    }
    
    let newOffset = currentOffset + recognizer.translationInView(self).x
    var percent = percentage(offset: newOffset, width: bounds.width)
    let direction = percent > 0 ? Direction.Right : Direction.Left
    
    guard canSwipe(direction) else {
      return
    }
    
    switch (recognizer.state) {
    case .Began, .Changed:
      dragging = true
      if swipable {
        swipingConstraint.constant = newOffset
      } else {
        if abs(percent) > trigger / 2 {
          cantSwipeLabel?.alpha = (abs(percent) - trigger / 2) / 0.5
        }
        // Can't swipe so create elastic effect
        frame.origin.x = trigger * bounds.width * tanh(newOffset / 200)
        percent = percentage(offset: frame.origin.x, width: bounds.width)
      }
      animateSwipe(direction, percentage: percent)
    
      delegate?.swiping?(self, percentage: percent)
    case .Cancelled, .Ended:
      let velocity = recognizer.velocityInView(self)
      dragging = false
      
      if swipable && abs(percent) > trigger {
        finish(duration: animationDuration(fromVelocity: velocity), direction: direction)
      } else {
        // Hide not swipable text
        if !swipable {
          UIView.animateWithDuration(NSTimeInterval(animationDuration)) {
            self.cantSwipeLabel?.alpha = 0
          }
        } else {
          reset(direction)
        }
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
  
  private func animationDuration(fromVelocity velocity: CGPoint) -> CGFloat {
    let width = bounds.width
    var horizontalVelocity = velocity.x
    
    if horizontalVelocity < -width {
      horizontalVelocity = -width
    } else if (horizontalVelocity > width) {
      horizontalVelocity = width
    }
    
    return Defaults.DurationHighLimit + Defaults.DurationLowLimit -
           abs(((horizontalVelocity / width) * Defaults.AnimationDurationDiff));
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
    if let iconView = iconViews[direction.hashValue] {
      if options[direction.hashValue].contains(.Alpha) {
        iconView.alpha = min(abs(percentage / (Defaults.AlphaRate * trigger)), 1)
      }
      var transform = CGAffineTransformIdentity
      if options[direction.hashValue].contains(.Scale) {
        let scalePercentage = scale(percentage: abs(percentage))
        transform = CGAffineTransformScale(transform, scalePercentage, scalePercentage)
      }
      if options[direction.hashValue].contains(.Rotate) {
        transform = CGAffineTransformRotate(transform, rotation(percentage: percentage))
      }
      iconView.transform = transform
    }
  }
  
  private func finish(duration duration: CGFloat, direction: Direction) {
    removeGestureRecognizer(recognizer)
    
    swipingConstraint.constant = direction == .Left ? -bounds.width : bounds.width
  
    UIView.animateWithDuration(NSTimeInterval(duration),
                               delay: NSTimeInterval(0),
                               options: [.CurveEaseOut],
                               animations: {
                                self.animateSwipe(direction, percentage: 1)
                                self.layoutIfNeeded()
    },
                               completion: { finished in
                                self.blocks[direction.hashValue]!(self)
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(self)
    })
  }
  
  private func reset(direction: Direction) {
    swipingConstraint.constant = 0
    
    UIView.animateWithDuration(NSTimeInterval(animationDuration),
                               delay: NSTimeInterval(0),
                               usingSpringWithDamping: Defaults.Damping,
                               initialSpringVelocity: Defaults.Velocity,
                               options: [.CurveEaseOut, .AllowUserInteraction],
                               animations: {
                                self.animateSwipe(direction, percentage: 0)
                                self.layoutIfNeeded()
      },
                               completion: { finished in
                                guard !self.dragging else {
                                  return
                                }
                                
                                self.uninstallSwipingView()
                                self.active = false
                                self.currentOffset = 0
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(self)
    })
  }
  
}
