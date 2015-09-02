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
  
  convenience init(context: NSManagedObjectContext, habit: Habit, due: NSDate, period: Int) {
    let entityDescription = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.due = due
    self.period = "\(habit.frequency.description)\(period)"
    habit.updateHistory(onDate: due, completed: 0, skipped: 0)
    //print("new entry: \(self.period)")
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
    var text = due!.timeAgoSinceNow()
    if dueIn > 0 {
      let endIndex = text.characters.count - 4
      text = "in \(text.substringToIndex(text.startIndex.advancedBy(endIndex)))"
    }
    return "\(Habit.frequencyStrings[habit!.frequency]!) (\(ratio)): \(text)"
    //return "\(due!)"
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
