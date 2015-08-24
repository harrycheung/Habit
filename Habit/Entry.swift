//
//  Entry.swift
//  Habit
//
//  Created by harry on 6/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class Entry: NSManagedObject {
  
  enum State: NSNumber {
    case Todo = 0, Skipped = 1, Completed = 2
  }
  
  convenience init(context: NSManagedObjectContext, habit: Habit, due: NSDate) {
    let entityDescription = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.due = due
    habit.updateHistory(onDate: due, completed: 0, skipped: 0)
  }
  
  var state: State {
    get { return State(rawValue: stateRaw!.integerValue)! }
    set { stateRaw = newValue.rawValue }
  }
  
  var dueIn: NSTimeInterval {
    return max(-NSDate().timeIntervalSinceDate(due!), 0)
  }
  
  var dueText: String {
    let due = Int(dueIn)
    let absDue = abs(due)
    var factor = 1
    let frequency = Habit.frequencyStrings[habit!.frequency]!
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
    //return "\(frequency): "
  }
  
  func complete() {
    state = .Completed
    habit!.currentStreak = habit!.currentStreak!.integerValue + 1
    if habit!.currentStreak!.integerValue > habit!.longestStreak!.integerValue {
      habit!.longestStreak = habit!.currentStreak
    }
    habit!.updateHistory(onDate: due!, completed: 1, skipped: 0)
  }
  
  func skip() {
    state = .Skipped
    habit!.currentStreak = 0
    habit!.updateHistory(onDate: due!, completed: 0, skipped: 1)
  }

}
