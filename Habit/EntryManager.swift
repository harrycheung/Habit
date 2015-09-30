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
  
  static var entriesCount: Int {
    return entries.count
  }
  
  static var upcoming: [Entry] {
    get { return EntryManager.instance.upcoming }
    set { EntryManager.instance.upcoming = newValue }
  }
  
  static var upcomingCount: Int {
    return upcoming.count
  }
  
  static func reload() {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND (due <= %@ || (due > %@ AND period IN %@))",
        Entry.State.Todo.rawValue, NSDate(), NSDate(), HabitApp.currentPeriods)
      instance.entries = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)",
        Entry.State.Todo.rawValue, NSDate(), HabitApp.currentPeriods)
      instance.upcoming = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
    } catch let error as NSError {
      NSLog("EntryManager.reload failed: \(error.localizedDescription)")
    }
  }
  
  static func updateNotifications() {
    if HabitApp.notification {
      UIApplication.sharedApplication().cancelAllLocalNotifications()
      var count = 0
      var number = 1
      let now = NSDate()
      for entry in entries {
        if count > 64 {
          break
        }
        if entry.habit!.notifyBool && entry.due!.compare(now) == .OrderedDescending {
          addNotification(entry, number: number)
          count += 1
        }
        number += 1
      }
      if count > 0 {
        HabitApp.initNotification()
      }
    }
  }
  
  private static func addNotification(entry: Entry, number: Int) {
    if HabitApp.notification {
      if UIApplication.sharedApplication().currentUserNotificationSettings()!.types.contains(.Alert) {
        let local = UILocalNotification()
        local.fireDate = entry.due
        local.alertBody = entry.habit!.name!
        local.userInfo = ["entry": entry.objectID.URIRepresentation().absoluteString]
        local.applicationIconBadgeNumber = number
        local.soundName = UILocalNotificationDefaultSoundName
        local.category = "HABIT_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(local)
      }
    }
  }
  
  static func removeNotification(entry: Entry) {
    if HabitApp.notification {
      if let notification = hasNotification(entry) {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }
  
  private static func hasNotification(entry: Entry) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if notification.userInfo!["entry"] as! String == entry.objectID.URIRepresentation().absoluteString {
        return notification
      }
    }
    return nil
  }
  
  static var overdue: Int {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due < %@", Entry.State.Todo.rawValue, NSDate())
      let result = try HabitApp.moContext.executeFetchRequest(request)
      return result.count
    } catch let error as NSError {
      NSLog("EntryManager.overdue failed: \(error.localizedDescription)")
      return 0
    }
  }
  
  static func complete(entry: Entry) {
    do {
      entry.complete()
      entries.removeAtIndex(entries.indexOf(entry)!)
      try HabitApp.moContext.save()
    } catch let error {
      NSLog("EntryManager.complete failed: \(error)")
    }
  }
  
  static func skip(entry: Entry) {
    do {
      entry.skip()
      entries.removeAtIndex(entries.indexOf(entry)!)
      try HabitApp.moContext.save()
    } catch let error {
      NSLog("EntryManager.skip failed: \(error)")
    }
  }
  
  static func skip(habit: Habit) -> [Int] {
    do {
      let before = NSDate(timeIntervalSinceNow: HabitApp.autoSkipDelayTimeInterval)
      var indexes: [Int] = []
      var newEntries: [Entry] = []
      for (index, entry) in entries.enumerate() {
        if entry.habit! == habit && entry.due!.compare(before) == .OrderedAscending {
          entry.skip()
          indexes.append(index)
        } else {
          newEntries.append(entry)
        }
      }
      entries = newEntries
      try HabitApp.moContext.save()
      return indexes
    } catch let error {
      NSLog("EntryManager.skip failed: \(error)")
      return []
    }
  }
  
}
