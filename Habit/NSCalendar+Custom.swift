//
//  NSCalendar+Custom.swift
//  Habit
//
//  Created by harry on 8/26/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation

extension NSCalendar {
  
  func components(unitFlags: NSCalendarUnit,
    fromDate: NSDate,
    toDate: NSDate) -> NSDateComponents {
    return components(unitFlags, fromDate: fromDate, toDate: toDate, options: NSCalendarOptions(rawValue: 0))
  }
  
  func dateByAddingUnit(unit: NSCalendarUnit,
    value: Int,
    toDate date: NSDate) -> NSDate? {
    return dateByAddingUnit(unit, value: value, toDate: date, options: NSCalendarOptions(rawValue: 0))
  }
  
  func zeroTime(date: NSDate) -> NSDate {
    return dateFromComponents(components([.Year, .Month, .Day], fromDate: date))!
  }
  
}