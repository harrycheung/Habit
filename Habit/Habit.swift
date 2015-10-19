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
    
    var description: String { return Habit.frequencyStrings[rawValue] }
    var unit: String { return Habit.frequencyUnitStrings[rawValue] }
  }
  
  static let frequencyStrings = ["Hourly", "Daily", "Weekly", "Monthly"]
  static let frequencyUnitStrings = ["hour", "day", "week", "month"]
  
  enum PartOfDay: Int {
    case Morning = 1, MidMorning = 2, MidDay = 3, Afternoon = 4, LateAfternoon = 5, Evening = 6
    
    var description: String { return Habit.partOfDayStrings[rawValue - 1] }
  }
  
  static let partOfDayStrings = [
    "Morning",
    "Midmorning",
    "Midday",
    "Afternoon",
    "Late Afternoon",
    "Evening"
  ]
  
  enum DayOfWeek: Int {
    case Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
    
    var description: String { return Habit.dayOfWeekStrings[rawValue - 1] }
    var shortDescription: String { return description.substringToIndex(description.startIndex.advancedBy(3)) }
  }
  
  static let dayOfWeekStrings = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]
  
  enum PartOfMonth: Int {
    case Beginning = 1, Middle = 2, End = 3
    
    var description: String { return Habit.partOfMonthStrings[rawValue - 1] }
  }
  
  static let partOfMonthStrings = [
    "Beginning",
    "Middle",
    "End"
  ]
  
  let endDayTimes = [
    PartOfDay.Morning: 9, PartOfDay.MidMorning: 11, PartOfDay.MidDay: 13,
    PartOfDay.Afternoon: 15, PartOfDay.LateAfternoon: 17, PartOfDay.Evening: HabitApp.endOfDay]
  
  // TODO: Check all usages of partsArray to see if we can just map - 1 here.
  var partsArray: [Int] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { Int(String($0))! } }
    set { parts = newValue.map({ String($0) }).joinWithSeparator(",") }
  }
  
  var frequency: Frequency {
    get { return Frequency(rawValue: frequencyRaw!.integerValue)! }
    set { frequencyRaw = newValue.rawValue }
  }
  
  var partsOfDay: [PartOfDay] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfDay(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joinWithSeparator(",") }
  }
  
  var daysOfWeek: [DayOfWeek] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { DayOfWeek(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joinWithSeparator(",") }
  }
  
  var partsOfMonth: [PartOfMonth] {
    get { return parts!.characters.split(isSeparator: { $0 == "," }).map { PartOfMonth(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joinWithSeparator(",") }
  }

  var timesInt: Int { return times!.integerValue }
  
  var useTimes: Bool { return parts!.isEmpty }
  
  var notifyBool: Bool {
    get { return notify!.boolValue }
    set { notify = NSNumber(bool: newValue) }
  }
  
  var neverAutoSkipBool: Bool {
    get { return neverAutoSkip!.boolValue }
    set { neverAutoSkip = NSNumber(bool: newValue) }
  }
  
  var pausedBool: Bool {
    get { return paused!.boolValue }
    set { paused = NSNumber(bool: newValue) }
  }
  
  var expectedCount: Int { return useTimes ? times!.integerValue : partsArray.count }
  
  convenience init(context: NSManagedObjectContext, name: String) {
    self.init(context: context, name: name, details: "", frequency: .Daily, times: 0, createdAt: NSDate())
  }
  
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
    neverAutoSkipBool = false
    pausedBool = false
    createdAtTimeZone = NSTimeZone.localTimeZone().name
    currentStreak = 0
    longestStreak = 0
    let _ = History(context: managedObjectContext!, habit: self, date: createdAt)
  }
  
  var hasOldEntries: Bool {
    var has = true
    switch frequency {
    case .Daily:
      has = HabitApp.calendar.components([.Day], fromDate: firstTodo!.due!, toDate: NSDate()).day >= 2
    case .Weekly:
      has = HabitApp.calendar.components([.Day], fromDate: firstTodo!.due!, toDate: NSDate()).day >= 14
    case .Monthly:
      has = HabitApp.calendar.components([.Month], fromDate: firstTodo!.due!, toDate: NSDate()).month >= 2
    default: ()
    }
    return has
  }
  
  private func addEntry(due due: NSDate, period: Int, number: Int) -> Entry {
    return Entry(context: managedObjectContext!, habit: self, due: due, period: period, number: number)
  }
  
  static func dateRange(date: NSDate, frequency: Frequency, includeEnd: Bool) -> (NSDate, NSDate) {
    let calendar = HabitApp.calendar
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
  
  func progress(date: NSDate) -> CGFloat {
    let denom = CGFloat(entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "due <= %@", date)).count)
    if denom == 0 {
      return completed!.integerValue > 0 ? 1 : 0
    }
    return min(CGFloat(completed!) / denom, 1)
  }

  func updateHistory(onDate date: NSDate, completedBy: Int, skippedBy: Int, totalBy: Int) {
    let (startDate, endDate) = dateRange(date)
    let predicate = NSPredicate(format: "date > %@ AND date <= %@ AND isDeleted == NO", startDate, endDate)
    if let history = histories!.filteredOrderedSetUsingPredicate(predicate).firstObject as? History {
      history.completed = history.completed!.integerValue + completedBy
      history.skipped = history.skipped!.integerValue + skippedBy
      history.total = history.total!.integerValue + totalBy
    } else {
      var historyDate = date
      if frequency == .Weekly {
        historyDate = HabitApp.calendar.dateByAddingUnit(.Day, value: -1, toDate: endDate)!
      }
      let history = History(context: managedObjectContext!, habit: self, date: historyDate)
      history.completed = completedBy
      history.skipped = skippedBy
      history.total = totalBy
    }
    completed = completed!.integerValue + completedBy
    skipped = skipped!.integerValue + skippedBy
  }
  
  func clearHistory(after date: NSDate) {
    // Delete current history and histories after
    let (startDate, _) = dateRange(date)
    let predicate = NSPredicate(format: "date > %@", startDate)
    for history in histories!.filteredOrderedSetUsingPredicate(predicate).array as! [History] {
      managedObjectContext!.deleteObject(history)
    }
    // Calculate new current history
    var completedBy = 0
    var skippedBy = 0
    for entry in entriesOnDate(date) {
      switch entry.state {
      case .Completed:
        completedBy++
      case .Skipped:
        skippedBy++
      default: ()
      }
    }
    updateHistory(onDate: date, completedBy: completedBy, skippedBy: skippedBy, totalBy: completedBy + skippedBy)
  }
  
  func countBefore(date: NSDate) -> Int {
    return countBefore(date, start: true)
  }
  
  //
  // countBefore
  //   # of entries before the 'date'. 'start' is true when used on a brand new habit. If true, count anything on 
  //   the date passed in, regardless if the times has passed or not.
  //
  func countBefore(var date: NSDate, start: Bool) -> Int {
    var count = 0
    let calendar = HabitApp.calendar
    switch frequency {
    case .Daily:
      let components = calendar.components([.Hour, .Minute], fromDate: date)
      var time = components.hour * 60 + components.minute
      if time == 0 {
        time = HabitApp.dayMinutes
      }
      if useTimes {
        time -= HabitApp.startOfDay
        if time >= HabitApp.endOfDay - HabitApp.startOfDay {
          count = times!.integerValue
        } else if time > 0 {
          let interval = (HabitApp.endOfDay - HabitApp.startOfDay) / times!.integerValue
          count = time / interval
        }
      } else {
        for partOfDay in partsOfDay {
          var endTime = endDayTimes[partOfDay]! * 60
          if partOfDay == .Evening {
            endTime = HabitApp.endOfDay
          }
          if time >= endTime {
            count++
          }
        }
      }
    case .Weekly:
      var components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Weekday], fromDate: date)
      var minuteOfDay = components.hour * 60 + components.minute
      if minuteOfDay == 0 {
        date = calendar.dateByAddingUnit(.Second, value: -1, toDate: date)!
        components = calendar.components([.Weekday], fromDate: date)
        minuteOfDay = HabitApp.dayMinutes
      }
      let weekday = components.weekday
      if useTimes {
        let dayMinutes = HabitApp.endOfDay - HabitApp.startOfDay
        if minuteOfDay < HabitApp.startOfDay {
          minuteOfDay = 0
        } else if minuteOfDay > HabitApp.endOfDay {
          minuteOfDay = HabitApp.endOfDay - HabitApp.startOfDay
        } else {
          minuteOfDay -= HabitApp.startOfDay
        }
        let time = (weekday - 1) * dayMinutes + minuteOfDay
        let interval = dayMinutes * 7 / times!.integerValue
        count = time / interval
      } else {
        for dayOfWeek in daysOfWeek {
          if weekday > dayOfWeek.rawValue {
            count++
          } else if weekday == dayOfWeek.rawValue {
            // Ignore minuteOfDay since this is a new habit
            if start || (!start && minuteOfDay >= HabitApp.endOfDay) {
              count++
            }
          }
        }
      }
    case .Monthly:
      var components = calendar.components([.Day, .Hour, .Minute], fromDate: date)
      var minuteOfDay = components.hour * 60 + components.minute
      if minuteOfDay == 0 {
        date = calendar.dateByAddingUnit(.Second, value: -1, toDate: date)!
        components = calendar.components([.Day], fromDate: date)
        minuteOfDay = HabitApp.dayMinutes
      }
      let day = components.day
      let daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date).length
      if useTimes {
        let interval = daysInMonth / times!.integerValue
        count = day / interval
      } else {
        for partOfMonth in partsOfMonth {
          if day > partOfMonth.rawValue * daysInMonth / 3 {
            count++
          } else if day == partOfMonth.rawValue * daysInMonth / 3 {
            // Ignore minuteOfDay since this is a new habit
            if start || (!start && minuteOfDay >= HabitApp.endOfDay) {
              count++
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
    //print("entries: \(formatter.stringFromDate(startDate)) \(formatter.stringFromDate(endDate))")
    predicates.append(NSPredicate(format: "due > %@ AND due <= %@", startDate, endDate))
    return entries!.filteredOrderedSetUsingPredicate(NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).array as! [Entry]
  }
  
  func skip(before date: NSDate) -> [Entry] {
    let predicate = NSPredicate(format: "due <= %@ AND stateRaw == %@", date, Entry.State.Todo.rawValue)
    let todoEntries = entries!.filteredOrderedSetUsingPredicate(predicate).array as! [Entry]
    for entry in todoEntries {
      entry.skip()
    }
    return todoEntries
  }
  
  var firstTodo: Entry? {
    let predicate = NSPredicate(format: "stateRaw == %@", Entry.State.Todo.rawValue)
    return entries!.filteredOrderedSetUsingPredicate(predicate).firstObject as? Entry
  }
  
  var lastEntry: NSDate {
    if entries!.count == 0 {
      return createdAt!
    } else {
      return (entries!.lastObject as! Entry).due!
    }
  }
  
  func update(currentDate: NSDate) -> [Entry] {
    return update(lastEntry, currentDate: currentDate)
  }
  
  func update(var lastDue: NSDate, currentDate: NSDate) -> [Entry] {
    var newEntries: [Entry] = []
    let calendar = HabitApp.calendar
    let expected = expectedCount
    let upcoming = (expected == 1 && useTimes && HabitApp.endOfDay == HabitApp.dayMinutes) ? 3 : 2
    var count = entries!.count == 0 ? countBefore(lastDue, start: true) : countBefore(lastDue, start: false)
    switch frequency {
    case .Daily:
//      if entries!.count == 0 {
//        lastDue = calendar.dateByAddingUnit(.Second, value: 5, toDate: NSDate())!
//        let components = calendar.components([.Day], fromDate: NSDate())
//        for index in 1..<5 {
//          lastDue = calendar.dateByAddingUnit(.Second, value: 5, toDate: lastDue)!
//          let _ = Entry(context: managedObjectContext!, habit: self, due: lastDue, period: components.day, number: index)
//        }
//      }
//      count = 4
      let upcomingDay = calendar.dateByAddingUnit(.Day, value: upcoming, toDate: currentDate)!
      let dayMinutes = HabitApp.endOfDay - HabitApp.startOfDay
      while true {
        //print("count: \(count)")
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: lastDue)
        if count >= expected {
          count = 0
          if components.hour != 0 {
            components.day++
          }
        }
        count++
        if useTimes {
          let dueTime = (dayMinutes / times!.integerValue) * (count) + HabitApp.startOfDay
          components.hour = dueTime / 60
          components.minute = dueTime % 60
        } else {
          let partOfDay = partsOfDay[count - 1]
          if partOfDay == .Evening {
            components.hour = HabitApp.endOfDay / 60
            components.minute = HabitApp.endOfDay % 60
          } else {
            components.hour = endDayTimes[partOfDay]!
            components.minute = 0
          }
        }
        lastDue = calendar.dateFromComponents(components)!
        // Need to special case the 1 time a day habit
        //print("\(expected) \(components.hour) \(formatter.stringFromDate(lastDue)) \(formatter.stringFromDate(upcomingDay))")
        if (expected == 1 || components.hour != 24) && calendar.isDate(lastDue, inSameDayAsDate: upcomingDay) {// lastDue.compare(upcomingDay) != .OrderedAscending {
          break
        }
        //print(HabitApp.dateFormatter.stringFromDate(lastDue))
        if pausedBool {
          updateHistory(onDate: lastDue, completedBy: 0, skippedBy: 0, totalBy: 0)
        } else {
          newEntries.append(addEntry(due: lastDue, period: components.day, number: count))
        }
      }
    case .Weekly:
      let beginningOfWeek = { (var date: NSDate) -> NSDate in
        // Get beginning of week
        let components = HabitApp.calendar.components([.Weekday], fromDate: date)
        date = HabitApp.calendar.dateByAddingUnit(.Day, value: 1 - components.weekday, toDate: date)!
        // Reset to midnight
        return HabitApp.calendar.dateFromComponents(calendar.components([.Year, .Month, .Day], fromDate: date))!
      }
      
      //print("expected: \(expected)")
      let upcomingWeek = calendar.dateByAddingUnit(.WeekOfYear, value: upcoming, toDate: currentDate)!
      //print("weekafternext: \(formatter.stringFromDate(upcomingWeek)) from \(formatter.stringFromDate(currentDate))")
      //print("lastEntry: \(formatter.stringFromDate(lastDue))")
//      if !useTimes && lastDue.compare(createdAt!) == .OrderedSame {
//        lastDue = beginningOfWeek(lastDue)
//        if HabitApp.endOfDay != HabitApp.dayMinutes {
//          lastDue = calendar.dateBySettingHour(HabitApp.endOfDay / 60, minute: HabitApp.endOfDay % 60, second: 0, ofDate: lastDue)!
//        }
      //      }
      let dayMinutes = HabitApp.endOfDay - HabitApp.startOfDay
      while true {
        if count >= expected {
          count = 1
          //print("new week")
          let components = calendar.components([.Weekday, .Hour], fromDate: lastDue)
          if components.weekday != 1 || (components.weekday == 1 && components.hour != 0) {
            lastDue = calendar.dateByAddingUnit(.Day, value: 7, toDate: lastDue)!
          }
          //print(formatter.stringFromDate(lastDue))
        } else {
          count++
        }
        let weekOfYear = calendar.components([.WeekOfYear], fromDate: lastDue).weekOfYear
        var dayIncrement = 0
        var dayTime = 0
        if useTimes {
          if count == times!.integerValue {
            if HabitApp.endOfDay != HabitApp.dayMinutes {
              dayIncrement = 6
              dayTime = HabitApp.endOfDay
            } else {
              dayIncrement = 7
            }
          } else {
            let increment = count * dayMinutes * 7 / times!.integerValue
            dayIncrement = increment / dayMinutes
            dayTime = increment % dayMinutes + HabitApp.startOfDay
          }
        } else {
          if HabitApp.endOfDay != HabitApp.dayMinutes {
            dayIncrement = daysOfWeek[count - 1].rawValue - 1
            dayTime = HabitApp.endOfDay
          } else {
            dayIncrement = daysOfWeek[count - 1].rawValue
          }
        }
        lastDue = calendar.dateByAddingUnit(.Day, value: dayIncrement, toDate: beginningOfWeek(lastDue))!
        lastDue = calendar.dateBySettingHour(dayTime / 60, minute: dayTime % 60, second: 0, ofDate: lastDue)!
        //print("new lastDue: \(formatter.stringFromDate(lastDue))")
        // If we are about the past our lookahead, stop
        let weekday = calendar.components([.Weekday], fromDate: lastDue).weekday
        if (expected == 1 || weekday != 1) && calendar.isDate(lastDue, equalToDate: upcomingWeek, toUnitGranularity: .WeekOfYear) {
          //print("\(formatter.stringFromDate(lastDue)) \(formatter.stringFromDate(upcomingWeek))")
          break
        }
        //print("new lastDue: \(formatter.stringFromDate(lastDue))")
        // Since we do calculations based on the beginning of the week, only create if we past createdAt
        if lastDue.compare(createdAt!) == .OrderedDescending {
          //print("new entry: \(HabitApp.dateFormatter.stringFromDate(lastDue))")
          if pausedBool {
            updateHistory(onDate: lastDue, completedBy: 0, skippedBy: 0, totalBy: 0)
          } else {
            newEntries.append(addEntry(due: lastDue, period: weekOfYear, number: count))
          }
        }
      }
    case .Monthly:
      let upcomingMonth = calendar.dateByAddingUnit(.Month, value: upcoming, toDate: currentDate)!
      while true {
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: lastDue)
        var daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: lastDue).length
        if count >= expected {
          count = 0
          if components.day != 1 {
            components.month++
            daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month,
              forDate: calendar.dateByAddingUnit(.Month, value: 1, toDate: lastDue)!).length
          }
        }
        count++
        if useTimes {
          let dueDay = count * daysInMonth / times!.integerValue
          components.day = dueDay
          components.hour = HabitApp.endOfDay / 60
          components.minute = HabitApp.endOfDay % 60
        } else {
          if (partsOfMonth[count - 1] == .End) {
            components.day = daysInMonth
          } else {
            components.day = (daysInMonth / 3) * (partsOfMonth[count - 1].rawValue)
          }
          components.hour = HabitApp.endOfDay / 60
          components.minute = HabitApp.endOfDay % 60
        }
        lastDue = calendar.dateFromComponents(components)!
        if (expected == 1 || components.day != daysInMonth) &&
          calendar.isDate(lastDue, equalToDate: upcomingMonth, toUnitGranularity: .Month) {
          break
        }
        //print("lastdue: \(HabitApp.dateFormatter.stringFromDate(lastDue))")
        if pausedBool {
          updateHistory(onDate: lastDue, completedBy: 0, skippedBy: 0, totalBy: 0)
        } else {
          newEntries.append(addEntry(due: lastDue, period: components.month, number: count))
        }
      }
    default: ()
    }
    return newEntries
  }

}
