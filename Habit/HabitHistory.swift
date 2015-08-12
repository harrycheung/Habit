//
//  HabitHistory.swift
//  Habit
//
//  Created by harry on 8/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class HabitHistory: UIView, UIScrollViewDelegate {
  
  var habit: Habit?
  var scrollView: UIScrollView?
  var scrollViewContent: UIView?
  var squares: [UIView] = []

  @IBInspectable var spacing: CGFloat = 3
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    scrollView = UIScrollView()
    scrollView!.delegate = self
    scrollView!.showsVerticalScrollIndicator = false
    scrollViewContent = UIView()
    scrollView!.addSubview(scrollViewContent!)
    scrollViewContent!.snp_makeConstraints({ (make) in
      make.edges.width.height.equalTo(scrollView!)
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
    scrollViewContent!.layer.borderColor = UIColor.redColor().CGColor
    scrollViewContent!.layer.borderWidth = 1.0
    if habit != nil && squares.isEmpty {
      let color = UIApplication.sharedApplication().windows[0].tintColor
      let calendar = NSCalendar.currentCalendar()
      let today = NSDate()
      var rightConstraint = scrollViewContent!.snp_right
      var rightOffset:CGFloat = 0
      
      switch habit!.frequency {
      case .Daily:
        let oneDay = NSDateComponents()
        oneDay.day = -1
        var dateIterator = today
        var lastDistance = 0
        while true {
          let percentage = habit!.percentageOnDate(dateIterator)
          if percentage == 0 && dateIterator.compare(habit!.createdAt!) == .OrderedAscending {
            break
          }
          let square = UIView()
//          square.layer.borderColor = UIColor.redColor().CGColor
//          square.layer.borderWidth = 1.0
          let alpha = 0.4 + (1 - 0.4) * pow(1000, -percentage)
          square.backgroundColor = UIColor(color: color, fadeToAlpha: alpha)
          let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: dateIterator)
          let weekday = components.weekday
          let distance = calendar.components([.Year, .WeekOfYear], fromDate: today).weekOfYear - calendar.components([.Year, .WeekOfYear], fromDate: dateIterator).weekOfYear
          if distance != lastDistance {
            lastDistance = distance
            rightConstraint = squares[squares.endIndex - 1].snp_left
            rightOffset = -spacing / 2.0
          }
          scrollViewContent!.addSubview(square)
          square.snp_makeConstraints({ (make) in
            make.right.equalTo(rightConstraint).offset(rightOffset)
            make.centerY.equalTo(scrollViewContent!).multipliedBy(CGFloat(1 + 2 * (weekday - 1)) / 7.0)
            make.height.equalTo(scrollViewContent!).multipliedBy(1 / 7.0).offset(-spacing / 2.0)
            make.width.equalTo(square.snp_height)
          })
          squares.append(square)
          dateIterator = calendar.dateByAddingComponents(oneDay, toDate: dateIterator, options: [])!
        }
      case .Weekly: ()
      case .Monthly: ()
      default: ()
      }
    }
  }
  
}
