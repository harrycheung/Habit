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
    scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
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
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y:  0, width:  frame.width, height:  frame.width))
        path.addRect(CGRect(x: 3, y:  3, width:  frame.width - 6, height:  frame.width - 6))
        mask.path = path
        mask.fillRule = kCAFillRuleEvenOdd
        square.layer.mask = mask
        square.backgroundColor = HabitApp.color
      } else {
        square.addGestureRecognizer(
          UITapGestureRecognizer(target: self,
                                 action: #selector(HabitHistory.squareTap))
        )
      }
    }
    
    let addLabel = { (content: UIView, date: Date) in
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM"
      let label = UILabel()
      label.text = dateFormatter.string(from: date)
      label.font = FontManager.regular(size: 13)
      label.textColor = UIColor.white
      content.addSubview(label)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.centerXAnchor.constraint(equalTo: self.squares[self.squares.endIndex - 1].centerXAnchor).isActive = true
      label.centerYAnchor.constraint(equalTo: content.topAnchor, constant: self.TitleBarHeight / 2).isActive = true
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
          let components = calendar.components([.weekday, .day], from: history.date! as Date)
          let weekday = components.weekday
          if !first && weekday == Habit.DayOfWeek.Sunday.rawValue {
            offset += side
          }
          let frame = CGRect(x: 
            offset, y:  TitleBarHeight + CGFloat(weekday! - 1) * side, width:  side - Spacing / 2, height:  side - Spacing / 2)
          addSquare(content, frame, history)
          if components.day == 1 {
            addLabel(content, history.date!)
          }
          if calendar.isDate(history.date!, equalTo: Date(), toUnitGranularity: .day) {
            break
          }
          first = false
        }
        offset += side - Spacing / 2
      case .Weekly:
        fallthrough
      case .Monthly:
        var lastMonth = calendar.components([.month], from: habit.createdAt!).month
        side = (contentHeight + Spacing / 2) / 6.0
        var count = 3
        for element in habit.histories! {
          let history = element as! History
          let frame = CGRect(x: offset, y:  TitleBarHeight, width:  side - Spacing / 2, height:  contentHeight)
          addSquare(content, frame, history)
          let month = calendar.components([.month], from: history.date!).month
          if (habit.frequency == .Weekly && lastMonth != month) ||
            (habit.frequency == .Monthly && count % 4 == 0) {
            addLabel(content, history.date!)
            lastMonth = month
          }
          offset += side
          count += 1
          if (habit.frequency == .Weekly &&
            calendar.isDate(history.date!, equalTo: Date(), toUnitGranularity: .weekOfYear)) ||
             (habit.frequency == .Monthly &&
              calendar.isDate(history.date!, equalTo: Date(), toUnitGranularity: .month)) {
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
        content.topAnchor.constraint(equalTo: outerContent.topAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: outerContent.rightAnchor).isActive = true
        content.widthAnchor.constraint(equalToConstant: offset).isActive = true
        content.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
        content = outerContent
        width = frame.width - 2 * Enlargement
        scroll = false
      }
      scrollView.addSubview(content)
      content.translatesAutoresizingMaskIntoConstraints = false
      content.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
      content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
      content.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
      content.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
      content.widthAnchor.constraint(equalToConstant: width).isActive = true
      content.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
      scrollView.contentInset = UIEdgeInsetsMake(0, Enlargement, 0, Enlargement)
      scrollView.layoutIfNeeded()
      if scroll {
        scrollView.setContentOffset(CGPoint(x: width - scrollView.frame.width + Enlargement, y:  0), animated: false)
      }
      
      var delay = 0.1
      for square in squares.reversed() {
        if square.frame.origin.x < width - scrollView.bounds.width - side {
          break
        }
        let endFrame = square.frame
        var startFrame = square.frame
        startFrame.origin.x = endFrame.origin.x - scrollView.bounds.width
        square.frame = startFrame
        UIView.animate(withDuration: 0.3,
          delay: delay,
          options: [.curveEaseOut],
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
  
  @objc func squareTap(recognizer: UITapGestureRecognizer) {
    clearSelection()
    let square = recognizer.view as! SquareView
    let frame = square.frame
    square.frame = CGRect(x: 
      frame.origin.x - Enlargement, y:  frame.origin.y - Enlargement, width: 
      frame.width + 2 * Enlargement, height:  frame.height + 2 * Enlargement)
    square.layer.borderColor = UIColor.black.cgColor
    square.layer.borderWidth = SelectedBorder
    square.superview!.bringSubview(toFront: square)
    selectedSquare = square
    delegate?.habitHistory(habitHistory: self, selectedHistory: square.history!)
  }
  
  func clearSelection() {
    if let square = selectedSquare {
      square.layer.borderColor = UIColor.clear.cgColor
      let frame = square.frame
      square.frame = CGRect(x: 
        frame.origin.x + Enlargement, y:  frame.origin.y + Enlargement, width: 
        frame.width - 2 * Enlargement, height:  frame.height - 2 * Enlargement)
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
