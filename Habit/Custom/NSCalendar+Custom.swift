//
//  NSCalendar+Custom.swift
//  Habit
//
//  Created by harry on 8/26/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

extension NSCalendar {
  
  func components(unitFlags: NSCalendar.Unit,
    fromDate: Date,
    toDate: Date) -> NSDateComponents {
    return components(unitFlags, from: fromDate as Date as Date, to: toDate as Date, options: NSCalendar.Options(rawValue: 0)) as NSDateComponents
  }
  
//  func date(byAdding unit: NSCalendar.Unit,
//            value: Int,
//            toDate date: Date) -> Date? {
//    return NSCalendar.current.date(byAdding: unit, value: value, to: date)
//  }
  
  func zeroTime(date: Date) -> Date {
    return NSCalendar.current.date(from: NSCalendar.current.dateComponents([.year, .month, .day], from: date))!
  }
  
//  func dateBySettingHour(h: Int,
//    minute m: Int,
//    second s: Int,
//    ofDate date: Date) -> Date? {
//    return NSCalendar.current.date(bySettingHour: h, minute: m, second: s, of: date)
//  }
  
//  func dateBySettingUnit(unit: NSCalendar.Unit,
//    value: Int,
//    ofDate date: Date) -> Date? {
//    return NSCalendar.current.date(bySettingUnit: unit, value: value, of: date, options: NSCalendar.Options(rawValue: 0))
//  }
  
}
