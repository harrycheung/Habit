//
//  Habit.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Habit)
class Habit: NSManagedObject {
  
  enum Frequency: Int {
    case Hourly, Daily, Weekly, Monthly, Annually
  }
  
  enum PartOfDay: Int {
    case Blank, Morning, MidMorning, MidDay, Afternoon, LateAfternoon, Evening
  }
  
  enum DayOfWeek: Int {
    case Blank, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
  }
  
  enum PartOfMonth: Int {
    case Blank, Beginning, Middle, End
  }
  
  let endDayTimes = [PartOfDay.Morning: 9, PartOfDay.MidMorning: 11, PartOfDay.MidDay: 13, PartOfDay.Afternoon: 15, PartOfDay.LateAfternoon: 17, PartOfDay.Evening: 24]
  
  var next: NSDate? = nil
  
  // TODO: Check all usages of partsArray to see if we can just map - 1 here.
  var partsArray: [Int] {
    get {
      return parts!.characters.split(isSeparator: { $0 == "," }).map { Int(String($0))! }
    }
    set {
      parts = ",".join(newValue.map { String($0) })
    }
  }
  
  var partsOfDay: [PartOfDay] {
    get {
      return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfDay(rawValue: Int(String($0))!)! }
    }
    set {
      parts = ",".join(newValue.map { String($0.rawValue) })
    }
  }
  
  var daysOfWeek: [DayOfWeek] {
    get {
      return parts!.characters.split(isSeparator: { $0 == "," }).map { DayOfWeek(rawValue: Int(String($0))!)! }
    }
    set {
      parts = ",".join(newValue.map { String($0.rawValue) })
    }
  }
  
  var partsOfMonth: [PartOfMonth] {
    get {
      return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfMonth(rawValue: Int(String($0))!)! }
    }
    set {
      parts = ",".join(newValue.map { String($0.rawValue) })
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
    return max(-NSDate().timeIntervalSinceDate(next!), 0)
  }
  
  var dueText: String {
    let due = Int(dueIn)
    let absDue = abs(due)
    var factor = 1
    var text = ""
    if absDue < 5 * HabitApp.minSec {
      return "now"
    } else if absDue < HabitApp.hourSec {
      factor = HabitApp.minSec
      text = "minute"
    } else if absDue < HabitApp.daySec {
      factor = HabitApp.hourSec
      text = "hour"
    } else if absDue < HabitApp.weekSec {
      factor = HabitApp.daySec
      text = "day"
    } else {
      factor = HabitApp.weekSec
      text = "week"
    }
    return "\(absDue / factor) \(text)" + (absDue < 2 * factor ? "" : "s") + (due < 0 ? " ago" : "")
  }
  
  convenience init(context: NSManagedObjectContext, name: String, details: String, frequency: Frequency, times: Int) {
    let entityDescription = NSEntityDescription.entityForName("Habit", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.name = name
    self.details = details
    self.frequency = frequency.hashValue
    self.times = times
    parts = ""
    notifyBool = true
    createdAt = NSDate()
    createdAtTimeZone = NSTimeZone.localTimeZone().name
    last = self.createdAt
    currentStreak = 0
    longestStreak = 0
    total = 0
  }
  
  func skippedCount(since: NSDate? = nil) -> Int {
    if since == nil {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "skipped == YES")).count
    } else {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "skipped == YES && createdAt > %@", since!)).count
    }
  }
  
  func completedCount(since: NSDate? = nil) -> Int {
    if since == nil {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "skipped == NO")).count
    } else {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "skipped == NO && createdAt > %@", since!)).count
    }
  }
  
  func totalCount(since: NSDate? = nil) -> Int {
    if since == nil {
      return total!.integerValue
    } else {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "createdAt > %@", since!)).count
    }
  }
  
  func progress(since: NSDate? = nil) -> CGFloat {
    if total!.integerValue == 0 {
      return 0
    } else {
      return CGFloat(completedCount(since)) / CGFloat(total!.integerValue)
    }
  }
  
  func addSkipped(count: Int, onDate date: NSDate) {
    for _ in 0..<count {
      let entry = Entry(context: self.managedObjectContext!, habit: self)
      entry.createdAt = date
      entry.skipped = true
    }
    currentStreak = 0
  }
  
  func countBeforeCreatedAt(date: NSDate) -> Int {
    var count = 0
    let calendar = NSCalendar.currentCalendar()
    switch Frequency(rawValue: frequency!.integerValue)! {
    case .Daily:
      if calendar.isDate(date, inSameDayAsDate: createdAt!) {
        let createdComponents = calendar.components([.Hour, .Minute], fromDate: createdAt!)
        let createdTime = NSTimeInterval(createdComponents.hour * HabitApp.hourSec + createdComponents.minute * HabitApp.minSec)
        if useTimes {
          let interval = Double(HabitApp.daySec) / times!.doubleValue
          count = Int(createdTime / interval)
        } else {
          for partOfDay in partsOfDay {
            if Double(endDayTimes[partOfDay]! * HabitApp.hourSec) < createdTime {
              count += 1
            }
          }
        }
      }
    case .Weekly:
      if calendar.isDate(date, equalToDate: createdAt!, toUnitGranularity: .WeekOfYear) {
        let createdComponents = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Weekday], fromDate: createdAt!)
        let createdTime = NSTimeInterval((createdComponents.weekday - 1) * HabitApp.daySec + createdComponents.hour * HabitApp.hourSec + createdComponents.minute * HabitApp.minSec)
        if useTimes {
          let interval = Double(HabitApp.weekSec) / times!.doubleValue
          count = Int(createdTime / interval)
        } else {
          for dayOfWeek in daysOfWeek {
            if createdComponents.weekday > dayOfWeek.rawValue {
              count += 1
            }
          }
        }
      }
    case .Monthly:
      if calendar.isDate(date, equalToDate: createdAt!, toUnitGranularity: .Month) {
        let createdDay = calendar.components([.Day], fromDate: createdAt!).day
        let daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date).length
        if useTimes {
          let interval = daysInMonth / Int(times!.doubleValue)
          count = createdDay / interval
        } else {
          for partOfMonth in partsOfMonth {
            if createdDay > partOfMonth.rawValue * daysInMonth / 3 {
              count += 1
            }
          }
        }
      }
    default: ()
    }
    return count
  }
  
  func entriesOnDay(day: NSDate) -> [Entry] {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day], fromDate: day)
    let startDate = calendar.dateFromComponents(components)!
    components.day += 1
    let endDate = calendar.dateFromComponents(components)!
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "createdAt >= %@ AND createdAt < %@", startDate, endDate)).array as! [Entry]
  }
  
  func entriesOnWeek(day: NSDate) -> [Entry] {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: day)
    components.weekday = 1
    let startDate = calendar.dateFromComponents(components)!
    components.weekOfYear += 1
    let endDate = calendar.dateFromComponents(components)!
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "createdAt >= %@ AND createdAt < %@", startDate, endDate)).array as! [Entry]
  }
  
  func entriesOnMonth(day: NSDate) -> [Entry] {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month], fromDate: day)
    let startDate = calendar.dateFromComponents(components)!
    components.month += 1
    let endDate = calendar.dateFromComponents(components)!
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "createdAt >= %@ AND createdAt < %@", startDate, endDate)).array as! [Entry]
  }
  
  func updateNext(currentDate: NSDate) {
    if currentDate.compare(last!) == .OrderedAscending {
      return
    }
    let calendar = NSCalendar.currentCalendar()
    switch Frequency(rawValue: frequency!.integerValue)! {
    case .Daily:
      let entriesToday = entriesOnDay(currentDate)
      if entriesToday.count == 0 {
        // Today is a new day so let's catch up the past
        let expectedCount = useTimes ? times!.integerValue : partsOfDay.count
        var dateIterator = last!
        let components = calendar.components([.Year, .Month, .Day], fromDate: dateIterator)
        while !calendar.isDateInToday(dateIterator) {
          addSkipped(expectedCount - entriesOnDay(dateIterator).count - countBeforeCreatedAt(dateIterator), onDate: dateIterator)
          components.day += 1
          dateIterator = calendar.dateFromComponents(components)!
        }
      }
      let components = calendar.components([.Hour, .Minute], fromDate: currentDate)
      let currentTime = NSTimeInterval(components.hour * HabitApp.hourSec + components.minute * HabitApp.minSec)
      if useTimes {
        let interval = (HabitApp.endOfDay - HabitApp.startOfDay) / times!.doubleValue
        let expectedCount = Int(currentTime / interval) - countBeforeCreatedAt(currentDate)
        if entriesToday.count >= expectedCount {
          // Already caught up or ahead of schedule
          next = NSDate(timeInterval: interval * Double(entriesToday.count - expectedCount + 1) - currentTime % interval, sinceDate: currentDate)
        } else {
          // Behind schedule. Use -1 to test if we're halfway to the next expiry
          addSkipped(expectedCount - entriesToday.count - 1, onDate: currentDate)
          if (currentTime % interval) / interval > 0.5 {
            // Skip if we're over halfway to the next expiry
            addSkipped(1, onDate: currentDate)
            next = NSDate(timeInterval: interval - currentTime % interval, sinceDate: currentDate)
          } else {
            next = NSDate(timeInterval: -currentTime % interval, sinceDate: currentDate)
          }
        }
      } else {
        var startCount = entriesToday.count + countBeforeCreatedAt(currentDate)
        for index in startCount..<partsOfDay.count {
          let partEndTime = endDayTimes[partsOfDay[index]]!
          if currentTime - Double(partEndTime * HabitApp.hourSec) > Double(HabitApp.hourSec) {
            // Skip if we're over an hour past
            addSkipped(1, onDate: currentDate)
            startCount += 1
          } else {
            // Didn't expire yet
            next = NSDate(timeInterval: Double(partEndTime * HabitApp.hourSec) - currentTime, sinceDate: currentDate)
            break
          }
        }
        if startCount == partsOfDay.count {
          // Done for the day
          let firstPartEndTime = endDayTimes[partsOfDay[0]]!
          next = NSDate(timeInterval: Double(firstPartEndTime * HabitApp.hourSec + HabitApp.daySec) - currentTime, sinceDate: currentDate)
        }
      }
    case .Weekly:
      let entriesThisWeek = entriesOnWeek(currentDate)
      if entriesThisWeek.count == 0 {
        // Today marks a new week so let's catch up the past
        let expectedCount = useTimes ? times!.integerValue : daysOfWeek.count
        var dateIterator = last!
        let components = calendar.components([.Year, .Month, .Day], fromDate: dateIterator)
        while !calendar.isDate(dateIterator, equalToDate: currentDate, toUnitGranularity: .WeekOfYear) {
          addSkipped(expectedCount - entriesOnWeek(dateIterator).count - countBeforeCreatedAt(dateIterator), onDate: dateIterator)
          components.day += 7
          dateIterator = calendar.dateFromComponents(components)!
        }
      }
      let components = calendar.components([.Year, .Month, .Day, .Hour, .Weekday], fromDate: currentDate)
      let currentTime = Double((components.weekday - 1) * HabitApp.dayHours + components.hour)
      if useTimes {
        let interval = Double(HabitApp.weekHours) / times!.doubleValue
        let expectedCount = Int(currentTime / interval) - countBeforeCreatedAt(currentDate)
        if entriesThisWeek.count >= expectedCount {
          // Already caught up or ahead
          components.hour += Int(interval * Double(entriesThisWeek.count - expectedCount + 1) - currentTime % interval)
        } else {
          // Should never skip for -1 or expectedCount == 0, we -1 to test if we're halfway to the next expiry
          addSkipped(expectedCount - entriesThisWeek.count - 1, onDate: currentDate)
          if currentTime % interval / interval > 0.5 {
            // Skip if we're over halfway to the next expiry
            addSkipped(1, onDate: currentDate)
            components.hour += Int(interval - currentTime % interval)
          } else {
            components.hour -= Int(currentTime % interval)
          }
        }
      } else {
        components.hour = 0
        var startCount = entriesThisWeek.count + countBeforeCreatedAt(currentDate)
        for index in startCount..<daysOfWeek.count {
          let dayOfWeek = daysOfWeek[index].rawValue
          if components.weekday > dayOfWeek {
            // Skip if we've passed the day
            addSkipped(1, onDate: currentDate)
            startCount += 1
          } else {
            components.day += dayOfWeek - components.weekday + 1 // +1 for midnight
            break
          }
        }
        if startCount == daysOfWeek.count {
          // Done for the week
          components.day += daysOfWeek[0].rawValue + (7 - components.weekday) + 1
        }
      }
      next = calendar.dateFromComponents(components)
    case .Monthly:
      let entriesThisMonth = entriesOnMonth(currentDate)
      if entriesThisMonth.count == 0 {
        // Today marks a new month so let's catch up the past
        let expectedCount = useTimes ? times!.integerValue : partsOfMonth.count
        var dateIterator = last!
        let components = calendar.components([.Year, .Month], fromDate: dateIterator)
        while !calendar.isDate(dateIterator, equalToDate: currentDate, toUnitGranularity: .Month) {
          addSkipped(expectedCount - entriesOnMonth(dateIterator).count - countBeforeCreatedAt(dateIterator), onDate: dateIterator)
          components.month += 1
          dateIterator = calendar.dateFromComponents(components)!
        }
      }
      let components = calendar.components([.Year, .Month, .Day], fromDate: currentDate)
      let currentDay = Double(components.day)
      let daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: currentDate).length
      if useTimes {
        let interval = Double(daysInMonth) / times!.doubleValue
        let expectedCount = Int(currentDay / interval) - countBeforeCreatedAt(currentDate)
        if entriesThisMonth.count >= expectedCount {
          // Already caught up or ahead
          components.day += Int(interval * Double(entriesThisMonth.count - expectedCount + 1) - currentDay % interval) + 1
        } else {
          // Should never skip for -1 or expectedCount == 0, we -1 to test if we're halfway to the next expiry
          addSkipped(expectedCount - entriesThisMonth.count - 1, onDate: currentDate)
          if currentDay % interval / interval > 0.5 {
            // Skip if we're over halfway to the next expiry
            addSkipped(1, onDate: currentDate)
            components.day += Int(interval - currentDay % interval) + 1
          } else {
            components.day -= Int(currentDay % interval) + 1
          }
        }
      } else {
        var startCount = entriesThisMonth.count + countBeforeCreatedAt(currentDate)
        for index in startCount..<partsOfMonth.count {
          let partOfMonthEnd = partsOfMonth[index].rawValue * daysInMonth / 3
          if components.day > partOfMonthEnd {
            // Skip if we've passed the day
            addSkipped(1, onDate: currentDate)
            startCount += 1
          } else {
            components.day += partOfMonthEnd - Int(currentDay) + 1 // +1 for midnight
            break
          }
        }
        if startCount == partsOfMonth.count {
          // Done for the month
          components.month += 1
          let daysInNextMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: calendar.dateFromComponents(components)!).length
          components.day = partsOfMonth[0].rawValue * daysInNextMonth / 3 + 1
        }
      }
      next = calendar.dateFromComponents(components)!
    default: ()
    }
  }

}
