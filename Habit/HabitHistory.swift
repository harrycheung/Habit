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

@IBDesignable
class HabitHistory: UIView, UIScrollViewDelegate {
  
  var habit: Habit?
  var scrollView: UIScrollView?
  var scrollViewContent: UIView?
  var scrollViewContentWidth: Constraint?
  var squares: [UIView] = []

  @IBInspectable var spacing: CGFloat = 4
  
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
//    scrollViewContent!.layer.borderColor = UIColor.redColor().CGColor
//    scrollViewContent!.layer.borderWidth = 1.0
    if habit != nil && squares.isEmpty {
      let color = UIApplication.sharedApplication().windows[0].tintColor
      let calendar = NSCalendar.currentCalendar()
      let today = NSDate()
      var rightConstraint = scrollViewContent!.snp_right
      var rightOffset:CGFloat = 0
      var totalWidth: CGFloat = 0
      
      switch habit!.frequency {
      case .Daily:
        var lastDistance = 0
        for element in habit!.histories!.reverseObjectEnumerator() {
          let history = element as! History
          if history.percentage == 0 && history.date!.compare(habit!.createdAt!) == .OrderedAscending {
            break
          }
          let square = UIView()
          let alpha = HabitApp.MinimumAlpha + (1 - HabitApp.MinimumAlpha) * pow(1000, -history.percentage)
          square.backgroundColor = UIColor(color: color, fadeToAlpha: alpha)
          let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: history.date!)
          let weekday = components.weekday
          let distance = calendar.components([.Year, .WeekOfYear], fromDate: today).weekOfYear -
            calendar.components([.Year, .WeekOfYear], fromDate: history.date!).weekOfYear
          if distance != lastDistance {
            let lastSquare = squares[squares.endIndex - 1]
            lastDistance = distance
            rightConstraint = lastSquare.snp_left
            rightOffset = -spacing / 2.0
            
            lastSquare.layoutIfNeeded()
            totalWidth += lastSquare.frame.width + spacing / 2.0
          }
          scrollViewContent!.addSubview(square)
          square.snp_makeConstraints({ (make) in
            make.right.equalTo(rightConstraint).offset(rightOffset)
            make.centerY.equalTo(scrollViewContent!).multipliedBy(CGFloat(1 + 2 * (weekday - 1)) / 7.0)
            make.height.equalTo(scrollViewContent!).multipliedBy(1 / 7.0).offset(-spacing / 2.0)
            make.width.equalTo(square.snp_height)
          })
          squares.append(square)
        }
        
        // Reset width constraint
        let lastSquare = squares[squares.endIndex - 1]
        lastSquare.layoutIfNeeded()
        totalWidth += lastSquare.frame.width
        scrollViewContentWidth!.uninstall()
        scrollViewContent!.snp_makeConstraints({ (make) in
          scrollViewContentWidth = make.width.equalTo(totalWidth).constraint
        })
        scrollView!.layoutIfNeeded()
        let bottomOffset = CGPointMake(scrollViewContent!.frame.width - scrollView!.frame.width, 0)
        scrollView!.setContentOffset(bottomOffset, animated: false)
      case .Weekly: ()
      case .Monthly: ()
      default: ()
      }
    }
  }
  
}
