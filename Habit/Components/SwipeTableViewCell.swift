//
//  SwipeTableViewCell.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc protocol SwipeTableViewCellDelegate {
  @objc optional func startSwiping(cell: SwipeTableViewCell)
  @objc optional func swiping(cell: SwipeTableViewCell, percentage: CGFloat)
  @objc optional func endSwiping(cell: SwipeTableViewCell)
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
  
  struct TransformOptions : OptionSet {
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
  private var isActive: Bool = false
  private var isDragging: Bool = false
  private var currentOffset: CGFloat!
  private var trigger: CGFloat = Defaults.Trigger
  private var animationDuration: CGFloat = Defaults.AnimationDuration
  private var swipingView: UIView!
  private var swipingConstraint: NSLayoutConstraint!
  private var colorViews: [UIView]!
  
  // Options
  private var iconViews = [UIView?](repeating: nil, count: 2)
  private var colors = [UIColor?](repeating: nil, count: 2)
  private var blocks = [CompletionBlock?](repeating: nil, count: 2)
  private var options = [TransformOptions](repeating: TransformOptions.None, count: 2)
  
  var swipable: Bool = true
  var cantSwipeLabel: UIView?
  var delegate: SwipeTableViewCellDelegate?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    recognizer = UIPanGestureRecognizer()
    recognizer.delegate = self
    recognizer.addTarget(self, action: #selector(SwipeTableViewCell.handlePan))
    addGestureRecognizer(recognizer)
    
    initDefaults();
  }
  
  func initDefaults() {
    isActive = false
    isDragging = false
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
    isActive = true
    
    swipingView = UIImageView(image: image(view: self))
    addSubview(swipingView)
    swipingView.translatesAutoresizingMaskIntoConstraints = false
    swipingView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    swipingConstraint = swipingView.leftAnchor.constraint(equalTo: leftAnchor)
    swipingConstraint.isActive = true
    swipingView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    swipingView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    
    if let iconView = iconViews[Direction.Left.hashValue] {
      let view = UIView()
      view.backgroundColor = colors[Direction.Left.hashValue]
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      view.leftAnchor.constraint(equalTo: swipingView.rightAnchor).isActive = true
      view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
      view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
      colorViews.append(view)
      addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false
      iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      iconView.leftAnchor.constraint(equalTo: swipingView.rightAnchor,
                                                  constant: Defaults.IconViewMargin).isActive = true
    }

    if let iconView = iconViews[Direction.Right.hashValue] {
      let view = UIView()
      view.backgroundColor = colors[Direction.Right.hashValue]
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      view.rightAnchor.constraint(equalTo: swipingView.leftAnchor).isActive = true
      view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
      view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
      colorViews.append(view)
      addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false
      iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      iconView.rightAnchor.constraint(equalTo: swipingView.leftAnchor,
                                                   constant: -Defaults.IconViewMargin).isActive = true
    }
    
    if let view = cantSwipeLabel {
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
      view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      bringSubview(toFront: view)
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
  
  private func image(view: UIView) -> UIImage {
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!;
  }
  
  func setSwipeGesture(direction: Direction,
                       iconView: UIView,
                       color: UIColor,
                       options transformOptions: TransformOptions,
                       completion: @escaping CompletionBlock) {
    options[direction.hashValue] = transformOptions
    iconViews[direction.hashValue] = iconView
    colors[direction.hashValue] = color
    blocks[direction.hashValue] = completion
  }
  
  func canSwipe(direction: Direction) -> Bool {
    return iconViews[direction.hashValue] != nil
  }
  
  override func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
    if let panRecognizer = recognizer as? UIPanGestureRecognizer {
      let velocity = panRecognizer.velocity(in: self)
      if abs(velocity.x) > abs(velocity.y) {
        if (velocity.x < 0 && !canSwipe(direction: .Left)) || (velocity.x > 0 && !canSwipe(direction: .Right)) {
          return false
        }
        return true
      }
    }
    return false
  }
  
  
  @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    if recognizer.state == UIGestureRecognizerState.began {
      if !isActive {
        delegate?.startSwiping?(cell: self)
        installSwipingView()
        SwipeTableViewCell.swipeCellCount += 1
        cantSwipeLabel?.alpha = 0
      } else {
        currentOffset = (swipingView.layer.presentation()!).frame.origin.x
        swipingView.layer.removeAllAnimations()
        for view in iconViews {
          view?.layer.removeAllAnimations()
        }
        for view in colorViews {
          view.layer.removeAllAnimations()
        }
      }
    }
    
    let newOffset = currentOffset + recognizer.translation(in: self).x
    var percent = percentage(offset: newOffset, width: bounds.width)
    let direction = percent > 0 ? Direction.Right : Direction.Left
    
    guard canSwipe(direction: direction) else {
      return
    }
    
    switch (recognizer.state) {
    case .began, .changed:
      isDragging = true
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
      animateSwipe(direction: direction, percentage: percent)
    
      delegate?.swiping?(cell: self, percentage: percent)
    case .cancelled, .ended:
      let velocity = recognizer.velocity(in: self)
      isDragging = false
      
      if swipable && abs(percent) > trigger {
        finish(duration: animationDuration(fromVelocity: velocity), direction: direction)
      } else {
        // Hide not swipable text
        if !swipable {
          UIView.animate(withDuration: TimeInterval(animationDuration)) {
            self.cantSwipeLabel?.alpha = 0
          }
        } else {
          reset(direction: direction)
        }
      }
    default: ()
    }
  }
  
  private static func offset(percentage: CGFloat, width: CGFloat) -> CGFloat {
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
  
  private func percentage(offset: CGFloat, width: CGFloat) -> CGFloat {
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
  
  private func rotation(percentage: CGFloat) -> CGFloat {
    var rotation: CGFloat = 0.0
    if percentage > 0 && percentage < trigger {
      rotation = CGFloat(Double.pi) * percentage / trigger + CGFloat(Double.pi)
    } else if percentage < 0 && percentage > -trigger {
      rotation = CGFloat(Double.pi) * (1 + percentage) / trigger
    } else if percentage == 0 {
      rotation = CGFloat(Double.pi)
    }
    return rotation
  }
  
  private func scale(percentage: CGFloat) -> CGFloat {
    return min(abs(percentage / (Defaults.ScaleRate * trigger)), 1)
  }
  
  private func animateSwipe(direction: Direction, percentage: CGFloat) {
    if let iconView = iconViews[direction.hashValue] {
      if options[direction.hashValue].contains(.Alpha) {
        iconView.alpha = min(abs(percentage / (Defaults.AlphaRate * trigger)), 1)
      }
      var transform = CGAffineTransform.identity
      if options[direction.hashValue].contains(.Scale) {
        let scalePercentage = scale(percentage: abs(percentage))
        transform = CGAffineTransform(scaleX: scalePercentage, y: scalePercentage)
      }
      if options[direction.hashValue].contains(.Rotate) {
        let rotationPercentage = rotation(percentage: percentage)
        transform = CGAffineTransform(rotationAngle: rotationPercentage)
      }
      iconView.transform = transform
    }
  }
  
  private func finish(duration: CGFloat, direction: Direction) {
    removeGestureRecognizer(recognizer)
    
    swipingConstraint.constant = direction == .Left ? -bounds.width : bounds.width
  
    UIView.animate(withDuration: TimeInterval(duration),
                               delay: TimeInterval(0),
                               options: [.curveEaseOut],
                               animations: {
                                self.animateSwipe(direction: direction, percentage: 1)
                                self.layoutIfNeeded()
    },
                               completion: { finished in
                                self.blocks[direction.hashValue]!(self)
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(cell: self)
    })
  }
  
  private func reset(direction: Direction) {
    swipingConstraint.constant = 0
    
    UIView.animate(withDuration: TimeInterval(animationDuration),
                               delay: TimeInterval(0),
                               usingSpringWithDamping: Defaults.Damping,
                               initialSpringVelocity: Defaults.Velocity,
                               options: [.curveEaseOut, .allowUserInteraction],
                               animations: {
                                self.animateSwipe(direction: direction, percentage: 0)
                                self.layoutIfNeeded()
      },
                               completion: { finished in
                                guard !self.isDragging else {
                                  return
                                }
                                
                                self.uninstallSwipingView()
                                self.isActive = false
                                self.currentOffset = 0
                                SwipeTableViewCell.swipeCellCount -= 1
                                self.delegate?.endSwiping?(cell: self)
    })
  }
  
}
