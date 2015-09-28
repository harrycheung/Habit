//
//  EntryManager.swift
//  Habit
//
//  Created by harry on 9/28/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class EntryManager {
  
  private var entries = [Entry]()
  private var upcoming = [Entry]()
  
  private static var instance: EntryManager = {
    return EntryManager()
  }()
  
  static var entries: [Entry] {
    get { return EntryManager.instance.entries }
    set { EntryManager.instance.entries = newValue }
  }
  
  static var upcoming: [Entry] {
    get { return EntryManager.instance.upcoming }
    set { EntryManager.instance.upcoming = newValue }
  }
  
  static func reload() {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND (due <= %@ || (due > %@ AND period IN %@))",
        Entry.State.Todo.rawValue, NSDate(), NSDate(), HabitApp.currentPeriods)
      instance.entries = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      if HabitApp.upcoming {
        let request = NSFetchRequest(entityName: "Entry")
        request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)",
          Entry.State.Todo.rawValue, NSDate(), HabitApp.currentPeriods)
        instance.upcoming = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      } else {
        instance.upcoming = []
      }
    } catch let error as NSError {
      NSLog("EntryManager.reload failed: \(error.localizedDescription)")
    }
  }
  
}
