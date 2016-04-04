//
//  NSCalendar+Custom.swift
//  Habit
//
//  Created by harry on 10/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

extension NSCalendar {
  
  func date(year year: Int, month: Int, day: Int, hour: Int, minute: Int) -> NSDate? {
    let components = NSDateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    return dateFromComponents(components)
  }
  
}
