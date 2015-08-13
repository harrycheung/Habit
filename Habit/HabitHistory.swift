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
//    scrollView!.layer.borderColor = UIColor.redColor().CGColor
//    scrollView!.layer.borderWidth = 1.0
    scrollViewContent!.layoutIfNeeded()
    let contentFrame = scrollViewContent!.frame
    if habit != nil && squares.isEmpty {
      let color = UIApplication.sharedApplication().windows[0].tintColor
      let calendar = NSCalendar.currentCalendar()
      
      switch habit!.frequency {
      case .Daily:
        let side = (contentFrame.height + spacing / 2) / 7.0
        var offset: CGFloat = 0
        var lastDistance = 0
        for element in habit!.histories! {
          let history = element as! History
          let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: history.date!)
          let weekday = components.weekday
          let distance = calendar.components([.Year, .WeekOfYear], fromDate: habit!.createdAt!).weekOfYear -
            calendar.components([.Year, .WeekOfYear], fromDate: history.date!).weekOfYear
          if distance != lastDistance {
            lastDistance = distance
            offset += side
          }
          let frame = CGRectMake(offset, CGFloat(weekday - 1) * side, side - spacing / 2, side - spacing / 2)
          let square = SquareView(frame: frame, history: history)
          square.translatesAutoresizingMaskIntoConstraints = true
          let alpha = minimumAlpha + (1 - minimumAlpha) * history.percentage
          square.backgroundColor = UIColor(color: color, fadeToAlpha: alpha)
          scrollViewContent!.addSubview(square)
          squares.append(square)
          
          square.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "squareTap:"))
        }
        
        // Reset width constraint
        scrollViewContentWidth!.uninstall()
        offset += side - spacing / 2
        scrollViewContent!.snp_makeConstraints({ (make) in
          scrollViewContentWidth = make.width.equalTo(offset).constraint
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
  
  func squareTap(recognizer: UITapGestureRecognizer) {
    let squareView = recognizer.view as! SquareView
    delegate?.habitHistory(self, selectedHistory: squareView.history!)
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
