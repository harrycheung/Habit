//
//  HabitHistory.swift
//  Habit
//
//  Created by harry on 8/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@objc(HabitHistoryDelegate)
protocol HabitHistoryDelegate {
  
  func habitHistory(habitHistory: HabitHistory, selectedHistory: History)
  
}

@IBDesignable
class HabitHistory: UIView, UIScrollViewDelegate {
  
  @IBOutlet var delegate: HabitHistoryDelegate?

  let minimumAlpha: CGFloat = 0.1
  let titleBarHeight: CGFloat = 20
  let spacing: CGFloat = 3
  let enlargement: CGFloat = 5
  let selectedBorder: CGFloat = 2
  
  var habit: Habit?
  var scrollView: UIScrollView?
  var scrollViewContent: UIView?
  var scrollViewContentWidth: Constraint?
  var squares: [SquareView] = []
  var selectedSquare: SquareView?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    scrollView = UIScrollView()
    scrollView!.delegate = self
    scrollView!.showsVerticalScrollIndicator = false
    scrollView!.showsHorizontalScrollIndicator = false
    scrollViewContent = UIView()
    scrollView!.addSubview(scrollViewContent!)
    scrollViewContent!.snp_makeConstraints({ (make) in
      make.edges.height.equalTo(scrollView!)
      scrollViewContentWidth = make.width.equalTo(scrollView!).constraint
    })
    addSubview(scrollView!)
    scrollView!.snp_makeConstraints({ (make) in
      make.edges.equalTo(self)
    })
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func layoutSubviews() {
//    scrollView!.layer.borderColor = UIColor.redColor().CGColor
//    scrollView!.layer.borderWidth = 1.0
    let addSquare = { (frame: CGRect, history: History) in
      let square = SquareView(frame: frame, history: history)
      square.translatesAutoresizingMaskIntoConstraints = true
      let alpha = self.minimumAlpha + (1 - self.minimumAlpha) * history.percentage
      square.backgroundColor = UIColor(color: HabitApp.color, fadeToAlpha: alpha)
      self.scrollViewContent!.addSubview(square)
      self.squares.append(square)
      
      square.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "squareTap:"))
    }
    
    let addLabel = { (date: NSDate) in
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "MMM"
      let label = UILabel()
      label.text = dateFormatter.stringFromDate(date)
      label.font = UIFont(name: "Bariol-Regular", size: 13.0)!
      label.textColor = UIColor.blackColor()
      self.scrollViewContent!.addSubview(label)
      label.snp_makeConstraints({ (make) in
        make.centerX.equalTo(self.squares[self.squares.endIndex - 1])
        make.centerY.equalTo(self.scrollViewContent!.snp_top).offset(self.titleBarHeight / 2)
      })
    }
    
    scrollViewContent!.layoutIfNeeded()
    let contentHeight = scrollViewContent!.frame.height - titleBarHeight
    if habit != nil && squares.isEmpty {
      let calendar = NSCalendar.currentCalendar()
      var side: CGFloat = 0
      var offset: CGFloat = 0
      
      switch habit!.frequency {
      case .Daily:
        side = (contentHeight + spacing / 2) / 7.0
        for element in habit!.histories! {
          let history = element as! History
          let components = calendar.components([.Weekday, .Day], fromDate: history.date!)
          let weekday = components.weekday
          if weekday == Habit.DayOfWeek.Sunday.rawValue {
            offset += side
          }
          let frame = CGRectMake(offset, titleBarHeight + CGFloat(weekday - 1) * side, side - spacing / 2, side - spacing / 2)
          addSquare(frame, history)
          
          if components.day == 1 {
            addLabel(history.date!)
          }
        }
        offset += side - spacing / 2
      case .Weekly:
        fallthrough
      case .Monthly:
        var lastMonth = calendar.components([.Month], fromDate: habit!.createdAt!).month
        side = (contentHeight + spacing / 2) / 6.0
        var count = 3
        for element in habit!.histories! {
          let history = element as! History
          let frame = CGRectMake(offset, titleBarHeight, side - spacing / 2, contentHeight)
          addSquare(frame, history)
          let month = calendar.components([.Month], fromDate: history.date!).month
          if (habit!.frequency == .Weekly && lastMonth != month) ||
            (habit!.frequency == .Monthly && count % 4 == 0) {
            addLabel(history.date!)
            lastMonth = month
          }
          offset += side
          count += 1
        }
      default: ()
      }
      
      // Reset width constraint
      scrollViewContentWidth!.uninstall()
      scrollViewContent!.snp_makeConstraints({ (make) in
        scrollViewContentWidth = make.width.equalTo(offset).constraint
      })
      scrollView!.layoutIfNeeded()
      let rightOffset = CGPointMake(scrollViewContent!.frame.width - scrollView!.frame.width, 0)
      scrollView!.setContentOffset(rightOffset, animated: false)
    }
  }
  
  func squareTap(recognizer: UITapGestureRecognizer) {
    clearSelection()
    let calendar = NSCalendar.currentCalendar()
    let square = recognizer.view as! SquareView
    let frame = square.frame
    var (xOffset, yOffset, widthOffset, heightOffset) = (-enlargement, CGFloat(0), 2 * enlargement, 2 * enlargement)
    if habit!.frequency == .Daily {
      let components = calendar.components([.Weekday], fromDate: square.history!.date!)
      if components.weekday == 1 {
        yOffset -= selectedBorder
      } else if components.weekday == 7 {
        yOffset += -2 * enlargement + selectedBorder
      } else {
        yOffset -= enlargement
      }
    } else {
      yOffset -= 2 * selectedBorder
      heightOffset = 3 * selectedBorder
    }
    let granularity: NSCalendarUnit = habit!.frequency == .Monthly ? .Month : .WeekOfYear
    if calendar.isDate(square.history!.date!, equalToDate: NSDate(), toUnitGranularity: granularity) {
      xOffset += -enlargement + selectedBorder
    } else if calendar.isDate(square.history!.date!, equalToDate: habit!.createdAt!, toUnitGranularity: granularity) {
      xOffset += enlargement - selectedBorder
    }
    square.frame = CGRectMake(frame.origin.x + xOffset, frame.origin.y + yOffset, frame.width + widthOffset, frame.height + heightOffset)
    square.layer.borderColor = UIColor.whiteColor().CGColor
    square.layer.borderWidth = selectedBorder
    square.superview!.bringSubviewToFront(square)
    selectedSquare = square
    delegate?.habitHistory(self, selectedHistory: square.history!)
  }
  
  func clearSelection() {
    let calendar = NSCalendar.currentCalendar()
    if let square = selectedSquare {
      square.layer.borderColor = UIColor.clearColor().CGColor
      let frame = square.frame
      var (xOffset, yOffset, widthOffset, heightOffset) = (enlargement, CGFloat(0), -2 * enlargement, -2 * enlargement)
      if habit!.frequency == .Daily {
        let components = calendar.components([.Weekday], fromDate: square.history!.date!)
        if components.weekday == 1 {
          yOffset += selectedBorder
        } else if components.weekday == 7 {
          yOffset += 2 * enlargement - selectedBorder
        } else {
          yOffset += enlargement
        }
      } else {
        yOffset += 2 * selectedBorder
        heightOffset = -3 * selectedBorder
      }
      let granularity: NSCalendarUnit = habit!.frequency == .Monthly ? .Month : .WeekOfYear
      if calendar.isDate(square.history!.date!, equalToDate: NSDate(), toUnitGranularity: granularity) {
        xOffset += enlargement - selectedBorder
      } else if calendar.isDate(square.history!.date!, equalToDate: habit!.createdAt!, toUnitGranularity: granularity) {
        xOffset += -enlargement + selectedBorder
      }
      square.frame = CGRectMake(frame.origin.x + xOffset, frame.origin.y + yOffset,
        frame.width + widthOffset, frame.height + heightOffset)
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
