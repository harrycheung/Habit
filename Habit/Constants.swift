//
//  Constants.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

struct Constants {
  
  // App colors
  static let green = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
  static let yellow = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
  
  // User color options
  static let blueTint = UIColor(red: 42.0 / 255.0, green: 132.0 / 255.0, blue: 219.0 / 255.0, alpha: 1)
  static let purpleTint = UIColor(red: 155.0 / 255.0, green: 79.0 / 255.0, blue: 172.0 / 255.0, alpha: 1)
  static let pinkTint = UIColor(red: 231.0 / 255.0, green: 84.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)
  static let darkBlueTint = UIColor(red: 52.0 / 255.0, green: 73.0 / 255.0, blue: 120.0 / 255.0, alpha: 1)
  static let redTint = UIColor(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
  static let orangeTint = UIColor(red: 255.0 / 255.0, green: 140.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
  static let colors = [purpleTint, darkBlueTint, blueTint, orangeTint, pinkTint, redTint]
  static let colorsNameToIndex = ["purple": 0, "darkBlue": 1, "blue": 2, "orange": 3, "pink": 4, "red": 5]
  
  static let minSec = 60
  static let hourSec = 60 * minSec
  static let daySec = dayHours * hourSec
  static let weekSec = 7 * daySec
  static let dayMinutes = hourMinutes * dayHours
  static let dayHours = 24
  static let hourMinutes = 60
  static let weekMinutes = 7 * dayMinutes
  static let weekHours = 7 * dayHours
  
  static let MinimumAlpha: CGFloat = 0.4
  static let NewButtonFadeAnimationDuration: NSTimeInterval = 0.2
  static let LayoutPriorityLow: UILayoutPriority = 900
  static let LayoutPriorityHigh: UILayoutPriority = 999
  static let TransitionOverlayAlpha: CGFloat = 0.2
  static let TransitionDuration: NSTimeInterval = 0.25
  static let ColorChangeAnimationDuration: NSTimeInterval = 0.5
  static let TableCellHeight: CGFloat = 70
  static let TableSectionHeight: CGFloat = 18
  
  static let TabAll = "All"
  static let TabToday = "Today"
  static let TabUpcoming = "Upcoming"
  
}