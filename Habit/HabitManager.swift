//
//  HabitManager.swift
//  Habit
//
//  Created by harry on 9/28/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class HabitManager {
  
  static func updateHabits() {
    do {
      let now = NSDate()
      let request = NSFetchRequest(entityName: "Habit")
      let habits = try HabitApp.moContext.executeFetchRequest(request) as! [Habit]
      for habit in habits {
        habit.update(now)
        if HabitApp.autoSkip && !habit.neverAutoSkipBool {
          habit.skip(before: NSDate(timeInterval: HabitApp.autoSkipDelayTimeInterval, sinceDate: now))
        }
      }
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("HabitManager.updateHabits failed: \(error.localizedDescription)")
    }
  }
  
}
