//
//  HabitHistory.swift
//  Habit
//
//  Created by harry on 8/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc protocol HabitHistoryDelegate {
  
  func habitHistory(habitHistory: HabitHistory, selectedHistory: History)
  
}

class HabitHistory: UIView {
  
  @IBOutlet var delegate: HabitHistoryDelegate?

  let MinimumAlpha: CGFloat = 0.1
  let TitleBarHeight: CGFloat = 20
  let Spacing: CGFloat = 3
  let Enlargement: CGFloat = 5
  let SelectedBorder: CGFloat = 2
  
  var habit: Habit!
  var scrollView: UIScrollView!
  var squares: [SquareView] = []
  var selectedSquare: SquareView?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    scrollView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
    scrollView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
    scrollView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let addSquare = { (content: UIView, frame: CGRect, history: History) in
      let square = SquareView(frame: frame, history: history)
      square.translatesAutoresizingMaskIntoConstraints = true
      let alpha = self.MinimumAlpha + (1 - self.MinimumAlpha) * history.percentage
      square.backgroundColor = UIColor(color: HabitApp.color, fadeToAlpha: alpha)
      content.addSubview(square)
      self.squares.append(square)
      
      if history.paused {
        let mask = CAShapeLayer()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, CGRectMake(0, 0, frame.width, frame.width))
        CGPathAddRect(path, nil, CGRectMake(3, 3, frame.width - 6, frame.width - 6))
        mask.path = path
        mask.fillRule = kCAFillRuleEvenOdd
        square.layer.mask = mask
        square.backgroundColor = HabitApp.color
      } else {
        square.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HabitHistory.squareTap(_:))))
      }
    }
    
    let addLabel = { (content: UIView, date: NSDate) in
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "MMM"
      let label = UILabel()
      label.text = dateFormatter.stringFromDate(date)
      label.font = FontManager.regular(13)
      label.textColor = UIColor.whiteColor()
      content.addSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.centerXAnchor.constraintEqualToAnchor(self.squares[self.squares.endIndex - 1].centerXAnchor).active = true
      label.centerYAnchor.constraintEqualToAnchor(content.topAnchor, constant: self.TitleBarHeight / 2).active = true
    }
    
    let contentHeight = frame.height - TitleBarHeight - Enlargement
    if habit != nil && squares.isEmpty {
      let calendar = HabitApp.calendar
      var side: CGFloat = 0
      var offset: CGFloat = 0
      var content = UIView()
      
      switch habit.frequency {
      case .Daily:
        var first = true
        side = (contentHeight + Spacing / 2) / 7.0
        for element in habit.histories! {
          let history = element as! History
          let components = calendar.components([.Weekday, .Day], fromDate: history.date!)
          let weekday = components.weekday
          if !first && weekday == Habit.DayOfWeek.Sunday.rawValue {
            offset += side
          }
          let frame = CGRectMake(
            offset, TitleBarHeight + CGFloat(weekday - 1) * side, side - Spacing / 2, side - Spacing / 2)
          addSquare(content, frame, history)
          if components.day == 1 {
            addLabel(content, history.date!)
          }
          if calendar.isDate(history.date!, equalToDate: NSDate(), toUnitGranularity: .Day) {
            break
          }
          first = false
        }
        offset += side - Spacing / 2
      case .Weekly:
        fallthrough
      case .Monthly:
        var lastMonth = calendar.components([.Month], fromDate: habit.createdAt!).month
        side = (contentHeight + Spacing / 2) / 6.0
        var count = 3
        for element in habit.histories! {
          let history = element as! History
          let frame = CGRectMake(offset, TitleBarHeight, side - Spacing / 2, contentHeight)
          addSquare(content, frame, history)
          let month = calendar.components([.Month], fromDate: history.date!).month
          if (habit.frequency == .Weekly && lastMonth != month) ||
            (habit.frequency == .Monthly && count % 4 == 0) {
            addLabel(content, history.date!)
            lastMonth = month
          }
          offset += side
          count += 1
          if (habit.frequency == .Weekly &&
              calendar.isDate(history.date!, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear)) ||
             (habit.frequency == .Monthly &&
              calendar.isDate(history.date!, equalToDate: NSDate(), toUnitGranularity: .Month)) {
            break
          }
        }
      default: ()
      }
      
      var scroll = true
      var width = offset
      if offset < frame.width {
        let outerContent = UIView()
        outerContent.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        content.topAnchor.constraintEqualToAnchor(outerContent.topAnchor).active = true
        content.rightAnchor.constraintEqualToAnchor(outerContent.rightAnchor).active = true
        content.widthAnchor.constraintEqualToConstant(offset).active = true
        content.heightAnchor.constraintEqualToConstant(frame.height).active = true
        content = outerContent
        width = frame.width - 2 * Enlargement
        scroll = false
      }
      scrollView.addSubview(content)
      content.translatesAutoresizingMaskIntoConstraints = false
      content.topAnchor.constraintEqualToAnchor(scrollView.topAnchor).active = true
      content.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor).active = true
      content.leftAnchor.constraintEqualToAnchor(scrollView.leftAnchor).active = true
      content.rightAnchor.constraintEqualToAnchor(scrollView.rightAnchor).active = true
      content.widthAnchor.constraintEqualToConstant(width).active = true
      content.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
      scrollView.contentInset = UIEdgeInsetsMake(0, Enlargement, 0, Enlargement)
      scrollView.layoutIfNeeded()
      if scroll {
        scrollView.setContentOffset(CGPointMake(width - scrollView.frame.width + Enlargement, 0), animated: false)
      }
      
      var delay = 0.1
      for square in squares.reverse() {
        if square.frame.origin.x < width - scrollView.bounds.width - side {
          break
        }
        let endFrame = square.frame
        var startFrame = square.frame
        startFrame.origin.x = endFrame.origin.x - scrollView.bounds.width
        square.frame = startFrame
        UIView.animateWithDuration(0.3,
          delay: delay,
          options: [.CurveEaseOut],
          animations: {
            square.frame = endFrame
          }, completion: nil)
        if habit.frequency == .Daily {
          delay += 0.005
        } else {
          delay += 0.01
        }
      }
    }
  }
  
  func squareTap(recognizer: UITapGestureRecognizer) {
    clearSelection()
    let square = recognizer.view as! SquareView
    let frame = square.frame
    square.frame = CGRectMake(
      frame.origin.x - Enlargement, frame.origin.y - Enlargement,
      frame.width + 2 * Enlargement, frame.height + 2 * Enlargement)
    square.layer.borderColor = UIColor.blackColor().CGColor
    square.layer.borderWidth = SelectedBorder
    square.superview!.bringSubviewToFront(square)
    selectedSquare = square
    delegate?.habitHistory(self, selectedHistory: square.history!)
  }
  
  func clearSelection() {
    if let square = selectedSquare {
      square.layer.borderColor = UIColor.clearColor().CGColor
      let frame = square.frame
      square.frame = CGRectMake(
        frame.origin.x + Enlargement, frame.origin.y + Enlargement,
        frame.width - 2 * Enlargement, frame.height - 2 * Enlargement)
      selectedSquare = nil
    }
  }
  
  class SquareView: UIView {
    
    var history: History?
    
    init(frame: CGRect, history: History) {
      super.init(frame: frame)
      self.history = history
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  }
  
}
