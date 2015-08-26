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

class Habit: NSManagedObject {
  
  enum Frequency: Int {
    case Hourly = 0, Daily = 1, Weekly = 2, Monthly = 3, Annually = 4
  }
  
  static let frequencyStrings = [Frequency.Daily: "Daily", Frequency.Weekly: "Weekly", Frequency.Monthly: "Monthly"]
  
  enum PartOfDay: Int {
    case Blank = 0, Morning = 1, MidMorning = 2, MidDay = 3, Afternoon = 4, LateAfternoon = 5, Evening = 6
  }
  
  enum DayOfWeek: Int {
    case Blank = 0, Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
  }
  
  enum PartOfMonth: Int {
    case Blank = 0, Beginning = 1, Middle = 2, End = 3
  }
  
  let endDayTimes = [PartOfDay.Morning: 9, PartOfDay.MidMorning: 11, PartOfDay.MidDay: 13, PartOfDay.Afternoon: 15, PartOfDay.LateAfternoon: 17, PartOfDay.Evening: 24]
  
  // TODO: Check all usages of partsArray to see if we can just map - 1 here.
  var partsArray: [Int] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { Int(String($0))! } }
    set { parts = ",".join(newValue.map { String($0) }) }
  }
  
  var frequency: Frequency {
    get { return Frequency(rawValue: frequencyRaw!.integerValue)! }
    set { frequencyRaw = newValue.rawValue }
  }
  
  var partsOfDay: [PartOfDay] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfDay(rawValue: Int(String($0))!)! } }
    set { parts = ",".join(newValue.map { String($0.rawValue) }) }
  }
  
  var daysOfWeek: [DayOfWeek] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { DayOfWeek(rawValue: Int(String($0))!)! } }
    set { parts = ",".join(newValue.map { String($0.rawValue) }) }
  }
  
  var partsOfMonth: [PartOfMonth] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfMonth(rawValue: Int(String($0))!)! } }
    set { parts = ",".join(newValue.map { String($0.rawValue) }) }
  }

  var timesInt: Int { return times!.integerValue }
  
  var useTimes: Bool { return parts!.isEmpty }
  
  var notifyBool: Bool {
    get { return notify!.boolValue }
    set { notify = NSNumber(bool: newValue) }
  }
  
  var isNew: Bool { return committedValuesForKeys(nil).count == 0 }
  
  var expectedCount: Int { return useTimes ? times!.integerValue : partsArray.count }
  
  convenience init(context: NSManagedObjectContext, name: String, details: String, frequency: Frequency, times: Int, createdAt: NSDate) {
    let entityDescription = NSEntityDescription.entityForName("Habit", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.name = name
    self.details = details
    self.frequency = frequency
    self.times = times
    self.createdAt = createdAt
    parts = ""
    notifyBool = true
    createdAtTimeZone = NSTimeZone.localTimeZone().name
    last = self.createdAt
    currentStreak = 0
    longestStreak = 0
    total = 0
    let _ = History(context: managedObjectContext!, habit: self, date: createdAt)
  }
  
  func skippedCount() -> Int {
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "stateRaw == %@", Entry.State.Skipped.rawValue)).count
  }
  
  func completedCount() -> Int {
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "stateRaw == %@", Entry.State.Completed.rawValue)).count
  }
  
  func totalCount(upTo: NSDate? = nil) -> Int {
    if upTo == nil {
      return total!.integerValue
    } else {
      return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "due <= %@", upTo!)).count
    }
  }
  
  func progress(upTo: NSDate? = nil) -> CGFloat {
    if total!.integerValue == 0 {
      return 0
    } else {
      return CGFloat(completedCount()) / CGFloat(totalCount(upTo))
    }
  }
  
  static func dateRange(date: NSDate, frequency: Frequency, includeEnd: Bool) -> (NSDate, NSDate) {
    let calendar = NSCalendar.currentCalendar()
    var startDate = NSDate()
    var endDate = NSDate()
    switch frequency {
    case .Daily:
      let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
      if (components.hour == 0 && components.minute == 0 && components.second == 0) {
        components.day -= 1
      } else {
        components.hour = 0
        components.minute = 0
        components.second = 0
      }
      startDate = calendar.dateFromComponents(components)!
      endDate = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate)!
    case .Weekly:
      let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour, .Minute, .Second], fromDate: date)
      if (components.weekday == 1 && components.hour == 0 && components.minute == 0 && components.second == 0) {
        endDate = calendar.dateByAddingUnit(.Day, value: includeEnd ? 0 : -1, toDate: date)!
        startDate = calendar.dateByAddingUnit(.WeekOfYear, value: -1, toDate: date)!
      } else {
        startDate = calendar.zeroTime(calendar.dateByAddingUnit(.Day, value: 1 - components.weekday, toDate: date)!)
        endDate = calendar.dateByAddingUnit(.Day, value: 6 + (includeEnd ? 1 : 0), toDate: startDate)!
      }
    case .Monthly:
      let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
      if (components.day == 1 && components.hour == 0 && components.minute == 0 && components.second == 0) {
        components.month -= 1
      } else {
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
      }
      startDate = calendar.dateFromComponents(components)!
      endDate = calendar.dateByAddingUnit(.Month, value: 1, toDate: startDate)!
    default: ()
    }
    return (startDate, endDate)
  }
  
  func dateRange(date: NSDate) -> (NSDate, NSDate) {
    return Habit.dateRange(date, frequency: frequency, includeEnd: true)
  }
  
  func updateHistory(onDate date: NSDate, completed: Int, skipped: Int) {
//    let formatter = NSDateFormatter();
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
//    formatter.timeZone = NSTimeZone(abbreviation: "PST");
//    
    let (startDate, endDate) = dateRange(date)
    let predicate = NSPredicate(format: "date > %@ AND date <= %@", startDate, endDate)
    if let history = histories!.filteredOrderedSetUsingPredicate(predicate).firstObject as? History {
      history.completed = history.completed!.integerValue + completed
      history.skipped = history.skipped!.integerValue + skipped
    } else {
      var historyDate = date
      if frequency == .Weekly {
        historyDate = HabitApp.calendar.dateByAddingUnit(.Day, value: -1, toDate: endDate)!
      }
      let history = History(context: managedObjectContext!, habit: self, date: historyDate)
      history.completed = completed
      history.skipped = skipped
    }
  }
  
  func countBeforeCreatedAt(date: NSDate) -> Int {
    var count = 0
    let calendar = NSCalendar.currentCalendar()
    switch frequency {
    case .Daily:
      if calendar.isDate(date, inSameDayAsDate: createdAt!) {
        let createdComponents = calendar.components([.Hour, .Minute], fromDate: createdAt!)
        let createdTime = NSTimeInterval(createdComponents.hour * HabitApp.hourSec + createdComponents.minute * HabitApp.minSec)
        if useTimes {
          let interval = Double(HabitApp.daySec) / times!.doubleValue
          count = Int(createdTime / interval)
        } else {
          for partOfDay in partsOfDay {
            if createdTime >= Double(endDayTimes[partOfDay]! * HabitApp.hourSec) {
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
            if createdComponents.weekday >= dayOfWeek.rawValue {
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
            if createdDay >= partOfMonth.rawValue * daysInMonth / 3 {
              count += 1
            }
          }
        }
      }
    default: ()
    }
    return count
  }
  
  func entriesOnDate(date: NSDate) -> [Entry] {
    return entriesOnDate(date, predicates: [])
  }
  
  func completedOnDate(date: NSDate) -> [Entry] {
    return entriesOnDate(date, predicates: [NSPredicate(format: "completed == YES")])
  }
  
  func percentageOnDate(date: NSDate) -> CGFloat {
    let entries = CGFloat(entriesOnDate(date).count)
    if entries == 0 {
      return 0
    } else {
      return CGFloat(completedOnDate(date).count) / entries
    }
  }
  
  func entriesOnDate(date: NSDate, var predicates: [NSPredicate]) -> [Entry] {
    let (startDate, endDate) = dateRange(date)
    predicates.append(NSPredicate(format: "due > %@ AND due <= %@", startDate, endDate))
    return entries!.filteredOrderedSetUsingPredicate(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).array as! [Entry]
  }
  
  func skipBefore(currentDate: NSDate) -> Int {
    var count = 0
    let todoEntries = entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "due <= %@ AND stateRaw == %@", currentDate, Entry.State.Todo.rawValue)).array as! [Entry]
    for entry in todoEntries {
      entry.skip()
      count += 1
    }
    return count
//    let request = NSBatchUpdateRequest(entityName: "Entry")
//    request.predicate = NSPredicate(format: "habit == %@ AND due > %@ AND due <= %@ AND stateRaw == %@",
//      self, last!, currentDate, Entry.State.Todo.rawValue)
//    request.propertiesToUpdate = ["stateRaw": Entry.State.Skipped.rawValue]
//    request.resultType = .UpdatedObjectsCountResultType
//    do {
//      let result = try managedObjectContext!.executeRequest(request) as! NSBatchUpdateResult
//      NSLog("\(result.result) objects updated")
//      return result.result as! Int
//    } catch let error as NSError{
//      NSLog("Could not perform batch request. Error = \(error)")
//      return 0
//    }
  }
  
  var lastEntry: NSDate {
    let request = NSFetchRequest(entityName: "Entry")
    request.fetchLimit = 1
    request.sortDescriptors = [NSSortDescriptor(key: "due", ascending: false)]
    request.predicate = NSPredicate(format: "habit == %@", self)
    do {
      let entries = try managedObjectContext!.executeFetchRequest(request) as! [Entry]
      if entries.count == 0 {
        return createdAt!
      } else {
        return entries[0].due!
      }
    } catch {
      return createdAt!
    }
  }
  
  func update(currentDate: NSDate) {
//    TODO: Remove
//    let formatter = NSDateFormatter();
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
//    formatter.timeZone = NSTimeZone(abbreviation: "PST");
    
    if currentDate.compare(last!) != .OrderedDescending {
      return
    }
    let calendar = HabitApp.calendar
    switch frequency {
    case .Daily:
      let expected = expectedCount
      let dayAfterTomorrow = calendar.dateByAddingUnit(.Day, value: 2, toDate: currentDate)!
      var lastDue = lastEntry
      var dayCount = entriesOnDate(lastDue).count
      var startOffset = countBeforeCreatedAt(lastDue)
      while true {
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: lastDue)
        if dayCount == expected - startOffset {
          dayCount = 0
          if components.hour != 0 {
            components.day += 1
          }
          // Offset goes to 0 on subsequent days
          startOffset = 0
        }
        dayCount += 1
        if useTimes {
          let dueTime = (HabitApp.dayMinutes / times!.integerValue) * (dayCount + startOffset)
          components.hour = dueTime / 60
          components.minute = dueTime % 60
        } else {
          components.hour = endDayTimes[partsOfDay[dayCount + startOffset - 1]]!
          components.minute = 0
        }
        lastDue = calendar.dateFromComponents(components)!
        if components.hour != 24 && calendar.isDate(lastDue, inSameDayAsDate: dayAfterTomorrow) {
          break
        }
        let entry = Entry(context: managedObjectContext!, habit: self, due: lastDue)
        entry.number = dayCount
        total = total!.integerValue + 1
      }
    case .Weekly:
      let beginningOfWeek = { (var date: NSDate, useTimes: Bool) -> NSDate in
        // Get beginning of week
        let components = HabitApp.calendar.components([.Weekday], fromDate: date)
        let offset = useTimes ? 1 : 0
        date = HabitApp.calendar.dateByAddingUnit(.Day, value: offset - components.weekday, toDate: date)!
        // Reset to midnight
        return HabitApp.calendar.dateFromComponents(calendar.components([.Year, .Month, .Day], fromDate: date))!
      }
      let expected = expectedCount
      let weekAfterNext = calendar.dateByAddingUnit(.WeekOfYear, value: 2, toDate: currentDate)!
      var lastDue = lastEntry
      var weekCount = entriesOnDate(lastDue).count
      if !useTimes && lastDue.compare(createdAt!) == .OrderedSame {
        lastDue = beginningOfWeek(lastDue, false)
      }
      while true {
        if weekCount == expected {
          weekCount = 1
        } else {
          weekCount += 1
        }
        if useTimes {
          // Calculate from beginning of week
          lastDue = beginningOfWeek(lastDue, true)
          lastDue = calendar.dateByAddingUnit(.Second, value: weekCount * HabitApp.weekSec / times!.integerValue, toDate: lastDue)!
          // Round to the hour
          lastDue = calendar.dateFromComponents(calendar.components([.Year, .Month, .Day, .Hour], fromDate: lastDue))!
        } else {
          let weekday = calendar.components([.Weekday], fromDate: lastDue).weekday
          let increment = daysOfWeek[weekCount - 1].rawValue + (weekCount == 1 ? 7 : 0) - (weekday == 1 ? 8 : weekday) + 1
          lastDue = calendar.dateByAddingUnit(.Day, value: increment, toDate: lastDue)!
        }
        // If we are about the past our lookahead, stop
        let weekday = calendar.components([.Weekday], fromDate: lastDue).weekday
        if weekday != 1 && calendar.isDate(lastDue, equalToDate: weekAfterNext, toUnitGranularity: .WeekOfYear) {
          break
        }
        // Since we do calculations based on the beginning of the week, only create if we past createdAt
        if lastDue.compare(createdAt!) == .OrderedDescending {
          let entry = Entry(context: managedObjectContext!, habit: self, due: lastDue)
          entry.number = weekCount
          total = total!.integerValue + 1
        }
      }
    case .Monthly:
      let expected = expectedCount
      let monthAfterNext = calendar.dateByAddingUnit(.Month, value: 2, toDate: currentDate)!
      var lastDue = lastEntry
      var monthCount = entriesOnDate(lastDue).count
      var startOffset = countBeforeCreatedAt(lastDue)
      while true {
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: lastDue)
        if monthCount == expected - startOffset {
          monthCount = 0
          startOffset = 0
          if components.day != 1 {
            components.month += 1
          }
        }
        monthCount += 1
        let daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: lastDue).length
        if useTimes {
          let dueDay = (daysInMonth / times!.integerValue) * (monthCount + startOffset)
          components.day = dueDay
          components.hour = 24
          components.minute = 0
        } else {
          if (partsOfMonth[monthCount + startOffset - 1] == .End) {
            components.day = daysInMonth
          } else {
            components.day = (daysInMonth / 3) * (partsOfMonth[monthCount + startOffset - 1].rawValue)
          }
          components.hour = 24
          components.minute = 0
        }
        lastDue = calendar.dateFromComponents(components)!
        if components.day != daysInMonth && calendar.isDate(lastDue, equalToDate: monthAfterNext, toUnitGranularity: .Month) {
          break
        }
        let entry = Entry(context: managedObjectContext!, habit: self, due: lastDue)
        entry.number = monthCount
        total = total!.integerValue + 1
      }
    default: ()
    }
  }

}
