//
//  Entry.swift
//  Habit
//
//  Created by harry on 6/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class Entry: NSManagedObject, Comparable {
  
  enum State: NSNumber {
    case Todo = 0, Skipped = 1, Completed = 2
  }
  
  convenience init(context: NSManagedObjectContext, habit: Habit, due: NSDate, period: Int, number: Int) {
    let entityDescription = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.due = due
    self.period = "\(habit.frequency.description)\(period)"
    self.number = number
    habit.updateHistory(onDate: due, completedBy: 0, skippedBy: 0, totalBy: 1)
    //print("\(habit.name) new entry: \(self.period)")
  }
  
  var state: State {
    get { return State(rawValue: stateRaw!.integerValue)! }
    set { stateRaw = newValue.rawValue }
  }
  
  var dueIn: NSTimeInterval {
    return due!.timeIntervalSinceDate(NSDate())
  }
  
  var dueText: String {
    var ratio = "\(number!) of \(habit!.expectedCount)"
    if !habit!.useTimes {
      switch habit!.frequency {
      case .Daily:
        ratio = "\(ratio) \(habit!.partsOfDay[number!.integerValue - 1].description)"
      case .Weekly:
        ratio = "\(habit!.daysOfWeek[number!.integerValue - 1].shortDescription) \(ratio)"
      case .Monthly:
        ratio = "\(ratio) \(habit!.partsOfMonth[number!.integerValue - 1].description)"
      default: ()
      }
    }
    var text = ""
    var di = Int(dueIn)
    let past = di < 0 ? true : false
    di = abs(di) / 60
    switch di {
    case 0..<5:
      text = "now"
    case 5..<60:
      text = "\(di) minutes"
    case 60..<HabitApp.dayMinutes:
      let hours = di / 60
      if hours == 1 {
        text = "an hour"
      } else {
        text = "\(hours) hours"
      }
    case HabitApp.dayMinutes..<HabitApp.weekMinutes:
      let days = di / HabitApp.dayMinutes
      if days == 1 {
        text = "a day"
      } else {
        text = "\(days) days"
      }
    case HabitApp.weekMinutes..<(HabitApp.weekMinutes * 4):
      let weeks = di / HabitApp.weekMinutes
      if weeks == 1 {
        text = "a week"
      } else {
        text = "\(weeks) weeks"
      }
    default:
      text = "a month"
    }
    if di >= 5 {
      if past {
        text = "\(text) ago"
      } else {
        text = "in \(text)"
      }
    }
    //return "\(Habit.frequencyStrings[habit!.frequency.rawValue]) (\(ratio)): due \(text)"
    return text
  }
  
  func complete() {
    state = .Completed
    habit!.currentStreak = habit!.currentStreak!.integerValue + 1
    if habit!.currentStreak!.integerValue > habit!.longestStreak!.integerValue {
      habit!.longestStreak = habit!.currentStreak
    }
    habit!.updateHistory(onDate: due!, completedBy: 1, skippedBy: 0, totalBy: 0)
  }
  
  func skip() {
    state = .Skipped
    habit!.currentStreak = 0
    habit!.updateHistory(onDate: due!, completedBy: 0, skippedBy: 1, totalBy: 0)
  }

}

func ==(x: Entry, y: Entry) -> Bool {
  return x.due!.compare(y.due!) == .OrderedSame && x.habit!.name! == y.habit!.name!
}

func <(x: Entry, y: Entry) -> Bool {
  if x.due!.compare(y.due!) == .OrderedSame {
    return x.habit!.name! < y.habit!.name!
  } else {
    return x.due!.compare(y.due!) == .OrderedAscending
  }
}
