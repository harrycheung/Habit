//
//  Habit+CoreDataClass.swift
//  Habit
//
//  Created by Harry on 10/4/17.
//  Copyright © 2017 Harry. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class Habit: NSManagedObject {

  enum Frequency: Int {
    case Hourly = 0, Daily = 1, Weekly = 2, Monthly = 3, Annually = 4
    
    var description: String { return Habit.frequencyStrings[rawValue] }
    var unit: String { return Habit.frequencyUnitStrings[rawValue] }
  }
  
  static let frequencyStrings = ["Hourly", "Daily", "Weekly", "Monthly"]
  static let frequencyUnitStrings = ["hour", "day", "week", "month"]
  
  enum PartOfDay: Int {
    case Morning = 1, MidDay = 2, Afternoon = 3, Evening = 4
    
    var description: String { return Habit.partOfDayStrings[rawValue - 1] }
  }
  
  static let partOfDayStrings = ["Morning",
                                 "Midday",
                                 "Afternoon",
                                 "Evening"]
  
  enum DayOfWeek: Int {
    case Sunday = 1, Monday = 2, Tuesday = 3, Wednesday = 4, Thursday = 5, Friday = 6, Saturday = 7
    
    var description: String { return Habit.dayOfWeekStrings[rawValue - 1] }
    var shortDescription: String { return String(description[..<description.index(description.startIndex, offsetBy: 3)]) }
  }
  
  static let dayOfWeekStrings = ["Sun",
                                 "Mon",
                                 "Tues",
                                 "Wed",
                                 "Thur",
                                 "Fri",
                                 "Sat"]
  
  enum PartOfMonth: Int {
    case Beginning = 1, Middle = 2, End = 3
    
    var description: String { return Habit.partOfMonthStrings[rawValue - 1] }
  }
  
  static let partOfMonthStrings = ["Beginning",
                                   "Middle",
                                   "End"]
  
  let endDayTimes = [PartOfDay.Morning: 9,
                     PartOfDay.MidDay: 13,
                     PartOfDay.Afternoon: 17,
                     PartOfDay.Evening: 21]
  
  // TODO: Check all usages of partsArray to see if we can just map - 1 here.
  var partsArray: [Int] {
    get { return parts!.components(separatedBy: ",").map { Int(String($0))! } }
    set { parts = newValue.map({ String($0) }).joined(separator: ",") }
  }
  
  var frequency: Frequency {
    get { return Frequency(rawValue: Int(frequencyRaw))! }
    set { frequencyRaw = Int32(newValue.rawValue) }
  }
  
  var partsOfDay: [PartOfDay] {
    get { return parts!.components(separatedBy: ",").map { PartOfDay(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joined(separator: ",") }
  }
  
  var daysOfWeek: [DayOfWeek] {
    get { return parts!.components(separatedBy: ",").map { DayOfWeek(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joined(separator: ",") }
  }
  
  var partsOfMonth: [PartOfMonth] {
    get { return parts!.components(separatedBy: ",").map { PartOfMonth(rawValue: Int(String($0))!)! } }
    set { parts = newValue.map({ String($0.rawValue) }).joined(separator: ",") }
  }
  
  var useTimes: Bool { return parts!.isEmpty }
  
  var expectedCount: Int { return useTimes ? Int(times) : partsArray.count }
  
  var isFake: Bool { return name == "" }
  
  convenience init(context: NSManagedObjectContext, name: String) {
    self.init(context: context, name: name, details: "", frequency: .Daily, times: 0, createdAt: Date())
  }
  
  convenience init(context: NSManagedObjectContext,
                   name: String,
                   details: String,
                   frequency: Frequency,
                   times: Int,
                   createdAt: Date) {
    let entityDescription = NSEntityDescription.entity(forEntityName: "Habit", in: context)!
    self.init(entity: entityDescription, insertInto: context)
    self.name = name
    self.details = details
    self.frequency = frequency
    self.times = Int32(times)
    self.createdAt = createdAt
    parts = ""
    notify = true
    paused = false
    createdAtTimeZone = TimeZone.current.identifier
    currentStreak = 0
    longestStreak = 0
    let _ = History(context: managedObjectContext!, habit: self, date: createdAt as Date)
  }
  
  static func dateRange(date: Date, frequency: Frequency, includeEnd: Bool) -> (Date, Date) {
    let calendar = HabitApp.calendar
    var startDate = Date()
    var endDate = Date()
    switch frequency {
    case .Daily:
      var components = calendar.components([.year, .month, .day, .hour, .minute, .second], from: date)
      if (components.hour == 0 && components.minute == 0 && components.second == 0) {
        components.day = components.day! - 1
      } else {
        components.hour = 0
        components.minute = 0
        components.second = 0
      }
      startDate = calendar.date(from: components)!
      endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
    case .Weekly:
      let components = calendar.components([.year, .weekOfYear, .weekday, .hour, .minute, .second], from: date)
      if (components.weekday == 1 && components.hour == 0 && components.minute == 0 && components.second == 0) {
        endDate = calendar.date(byAdding: .day, value: includeEnd ? 0 : -1, to: date)!
        startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: date)!
      } else {
        startDate = calendar.zeroTime(date: calendar.date(byAdding: .day, value: 1 - components.weekday!, to: date)!)
        endDate = calendar.date(byAdding: .day, value: 6 + (includeEnd ? 1 : 0), to: startDate)!
      }
    case .Monthly:
      var components = calendar.components([.year, .month, .day, .hour, .minute, .second], from: date)
      if (components.day == 1 && components.hour == 0 && components.minute == 0 && components.second == 0) {
        components.month = components.month! - 1
      } else {
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
      }
      startDate = calendar.date(from: components)!
      endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
    default: ()
    }
    return (startDate, endDate)
  }
  
  func dateRange(date: Date) -> (Date, Date) {
    return Habit.dateRange(date: date, frequency: frequency, includeEnd: true)
  }
  
  func progress(date: Date) -> CGFloat {
//    let denom = CGFloat(entries!.filtered(using: NSPredicate(format: "due <= %@", date as CVarArg)).count)
//    if denom == 0 {
//      return completed > 0 ? 1 : 0
//    }
//    return min(CGFloat(completed) / denom, 1)
    return 0
  }
  
  func updateHistory(onDate date: Date, completedBy: Int, skippedBy: Int, totalBy: Int) {
//    let (startDate, endDate) = dateRange(date: date)
//    let predicate = NSPredicate(format: "date > %@ AND date <= %@ AND isDeleted == NO", startDate as CVarArg, endDate as CVarArg)
//    if let history = histories!.filtered(using: predicate).firstObject as? History {
//      history.completed = history.completed + Int32(completedBy)
//      history.skipped = history.skipped + Int32(skippedBy)
//      history.total = history.total + Int32(totalBy)
//    } else {
//      var historyDate = date
//      if frequency == .Weekly {
//        historyDate = HabitApp.calendar.date(byAdding: .day, value: -1, to: endDate)!
//      }
//      let history = History(context: managedObjectContext!, habit: self, date: historyDate as Date)
//      history.completed = Int32(completedBy)
//      history.skipped = Int32(skippedBy)
//      history.total = Int32(totalBy)
//    }
//    completed = completed + Int32(completedBy)
//    skipped = skipped + Int32(skippedBy)
  }
  
  func clearHistory(after date: Date) {
//    // Delete current history and histories after
//    let (startDate, _) = dateRange(date: date)
//    let predicate = NSPredicate(format: "date > %@", startDate as CVarArg)
//    for history in histories!.filtered(using: predicate).array as! [History] {
//      managedObjectContext!.delete(history)
//    }
//    // Calculate new current history
//    var completedBy = 0
//    var skippedBy = 0
//    for entry in entriesOnDate(date: date) {
//      switch entry.state {
//      case .Completed:
//        completedBy += 1
//      case .Skipped:
//        skippedBy += 1
//      default: ()
//      }
//    }
//    updateHistory(onDate: date, completedBy: completedBy, skippedBy: skippedBy, totalBy: completedBy + skippedBy)
  }
  
  func countBefore(date: Date) -> Int {
    return countBefore(date: date, start: true)
  }
  
  //
  // countBefore
  //   # of entries before the 'date'. 'start' is true when used on a brand new habit. If true, count anything on
  //   the date passed in, regardless if the times has passed or not.
  //
  func countBefore(date: Date, start: Bool) -> Int {
    var date = date
    var count = 0
    let calendar = HabitApp.calendar
    switch frequency {
    case .Daily:
      let components = calendar.components([.hour, .minute], from: date)
      var time = components.hour! * 60 + components.minute!
      if time == 0 {
        time = Constants.dayMinutes
      }
      if useTimes {
        time -= HabitApp.startOfDay
        if time >= HabitApp.endOfDay - HabitApp.startOfDay {
          count = Int(times)
        } else if time > 0 {
          _ = (HabitApp.endOfDay - HabitApp.startOfDay) / Int(times)
        }
      } else {
        for partOfDay in partsOfDay {
          var endTime = endDayTimes[partOfDay]! * 60
          if partOfDay == .Evening {
            endTime = HabitApp.endOfDay
          }
          if time >= endTime {
            count += 1
          }
        }
      }
    case .Weekly:
      var components = calendar.components([.year, .month, .day, .hour, .minute, .weekday], from: date)
      var minuteOfDay = components.hour! * 60 + components.minute!
      if minuteOfDay == 0 {
        var minusOneSecond = DateComponents()
        minusOneSecond.second = -1
        date = calendar.date(byAdding: minusOneSecond, to: date)!
        components = calendar.components([.weekday], from: date)
        minuteOfDay = Constants.dayMinutes
      }
      let weekday = components.weekday!
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
        let interval = dayMinutes * 7 / Int(times)
        count = time / interval
      } else {
        for dayOfWeek in daysOfWeek {
          if weekday > dayOfWeek.rawValue {
            count += 1
          } else if weekday == dayOfWeek.rawValue {
            // Ignore minuteOfDay since this is a new habit
            if start || (!start && minuteOfDay >= HabitApp.endOfDay) {
              count += 1
            }
          }
        }
      }
    case .Monthly:
      var components = calendar.components([.day, .hour, .minute], from: date)
      var minuteOfDay = components.hour! * 60 + components.minute!
      if minuteOfDay == 0 {
        date = calendar.date(byAdding: .second, value: -1, to: date)!
        components = calendar.components([.day], from: date)
        minuteOfDay = Constants.dayMinutes
      }
      let day = components.day!
      let daysInMonth = calendar.range(of: .day, in: .month, for: date).length
      if useTimes {
        let interval = daysInMonth / Int(times)
        count = day / interval
      } else {
        for partOfMonth in partsOfMonth {
          if day > partOfMonth.rawValue * daysInMonth / 3 {
            count += 1
          } else if day == partOfMonth.rawValue * daysInMonth / 3 {
            // Ignore minuteOfDay since this is a new habit
            if start || (!start && minuteOfDay >= HabitApp.endOfDay) {
              count += 1
            }
          }
        }
      }
    default: ()
    }
    return count
  }
//  
//  func entriesOnDate(date: Date) -> [Entry] {
//    return entriesOnDate(date: date, predicates: [])
//  }
//  
//  func completedOnDate(date: Date) -> [Entry] {
//    return entriesOnDate(date: date, predicates: [NSPredicate(format: "completed == YES")])
//  }
//  
//  func percentageOnDate(date: Date) -> CGFloat {
//    let entries = CGFloat(entriesOnDate(date: date).count)
//    if entries == 0 {
//      return 0
//    } else {
//      return CGFloat(completedOnDate(date: date).count) / entries
//    }
//  }
  
//  func entriesOnDate(date: Date, predicates: [NSPredicate]) -> [Entry] {
//    var predicates = predicates
//    let (startDate, endDate) = dateRange(date: date)
//    //print("entries: \(formatter.string(from: startDate)) \(formatter.string(from: endDate))")
//    predicates.append(NSPredicate(format: "due > %@ AND due <= %@", startDate as CVarArg, endDate as CVarArg))
//    return entries!.filtered(using: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)).array as! [Entry]
//  }
//
//  func skip(before date: Date) -> [Entry] {
//    let predicate = NSPredicate(format: "due <= %@ AND stateRaw == %@", date as CVarArg, Entry.State.Todo.rawValue)
//    let todoEntries = entries!.filtered(using: predicate).array as! [Entry]
//    for entry in todoEntries {
//      entry.skip()
//    }
//    return todoEntries
//  }
//
  func update(currentDate: Date) {
    let lastHistory = histories!.lastObject as! History
    var lastDate = lastHistory.date!
    switch frequency {
    case .Daily:
      while lastDate < currentDate {
        lastDate = HabitApp.calendar.date(byAdding: .day, value: 1, to: lastDate)!
        let history = History(context: managedObjectContext!, habit: self, date: lastDate)
        do {
          try managedObjectContext!.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
      }
    case .Weekly:
      let beginningOfWeek = { (date: Date) -> Date in
        var date = date
        // Get beginning of week
        let components = HabitApp.calendar.components([.weekday], from: date)
        date = HabitApp.calendar.date(byAdding: .day, value: 1 - components.weekday!, to: date)!
        // Reset to midnight
        return HabitApp.calendar.date(from: HabitApp.calendar.components([.year, .month, .day], from: date))!
      }
    default: ()
    }
  }
  
}
