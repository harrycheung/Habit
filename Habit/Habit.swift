//
//  Habit.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

@objc(Habit)
class Habit: NSManagedObject {
  enum Frequency: Int {
    case Hourly, Daily, Weekly, Monthly, Annually
  }
  
  class func create(moc moc: NSManagedObjectContext, name: String, details: String, frequency: Frequency, times: Int) -> Habit {
    let habit = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: moc) as! Habit
    habit.name = name
    habit.details = details
    habit.frequency = frequency.hashValue
    habit.times = times
    habit.parts = ""
    habit.notifyBool = true
    habit.createdAt = NSDate()
    habit.createdAtTimeZone = NSTimeZone.localTimeZone().name
    habit.last = habit.createdAt
    return habit
  }
  var partsArray: [Int] {
    get {
      return split(parts!.characters, isSeparator: { $0 == "," }).map({Int(String($0))!})
    }
    set {
      parts = ",".join(newValue.map({ String($0) }))
    }
  }
  
  var timesInt: Int {
    return times!.integerValue
  }
  
  var useTimes: Bool {
    return parts!.isEmpty
  }
  
  var notifyBool: Bool {
    get {
      return notify!.boolValue
    }
    set {
      notify = NSNumber(bool: newValue)
    }
  }
  
  var isNew: Bool {
    return committedValuesForKeys(nil).count == 0
  }
  
  var dueIn: NSTimeInterval {
    var interval = 3600.0
    switch frequency!.integerValue {
    case Frequency.Daily.hashValue:
      interval *= 24
    case Frequency.Weekly.hashValue:
      interval *= 7 * 24
    case Frequency.Monthly.hashValue:
      interval *= 30 * 24
    case Frequency.Annually.hashValue:
      interval *= 365 * 24
    default: ()
    }
    return interval / times!.doubleValue - abs(last!.timeIntervalSinceNow)
  }
  
  var dueText: String {
    let due = Int(dueIn)
    let absDue = abs(due)
    var factor = 1
    var text = ""
    if absDue < 5 * 60 {
      return "now"
    } else if absDue < 3600 {
      factor = 60
      text = "minute"
    } else if absDue < (24 * 3600) {
      factor = 3600
      text = "hour"
    } else if absDue < (7 * 24 * 3600) {
      factor = 24 * 3600
      text = "day"
    } else {
      factor = 7 * 24 * 3600
      text = "week"
    }
    return "\(absDue / factor) \(text)" + (absDue < 2 * factor ? "" : "s") + (due < 0 ? " ago" : "")
  }

}
