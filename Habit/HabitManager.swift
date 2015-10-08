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
  
  private var current = [Entry]()
  private var upcoming = [Entry]()
  
  private static var instance: HabitManager = {
    return HabitManager()
    }()
  
  static var current: [Entry] {
    get { return HabitManager.instance.current }
    set { HabitManager.instance.current = newValue }
  }
  
  static var currentCount: Int {
    return current.count
  }
  
  static var upcoming: [Entry] {
    get { return HabitManager.instance.upcoming }
    set { HabitManager.instance.upcoming = newValue }
  }
  
  static var upcomingCount: Int {
    return upcoming.count
  }
  
  static func reload() {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND (due <= %@ || (due > %@ AND period IN %@))",
        Entry.State.Todo.rawValue, NSDate(), NSDate(), HabitApp.currentPeriods)
      instance.current = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)",
        Entry.State.Todo.rawValue, NSDate(), HabitApp.currentPeriods)
      instance.upcoming = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
    } catch let error as NSError {
      NSLog("HabitManager.reload failed: \(error.localizedDescription)")
    }
  }
  
  static func updateNotifications() {
    if HabitApp.notification {
      UIApplication.sharedApplication().cancelAllLocalNotifications()
      var count = 0
      var number = 1
      let now = NSDate()
      for entry in current {
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
  
  static func handleNotification(notification: UILocalNotification, identifier: String) {
    do {
      let entryURL = NSURL(string: notification.userInfo!["entry"] as! String)!
      let entryID = HabitApp.moContext.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(entryURL)!
      let entry = try HabitApp.moContext.existingObjectWithID(entryID) as! Entry
      let index = current.indexOf(entry)!
      switch (identifier) {
      case "COMPLETE":
        complete(index)
      case "SKIP":
        skip(index)
      default:
        return
      }
      UIApplication.sharedApplication().applicationIconBadgeNumber = HabitManager.overdue
      updateNotifications()
    } catch let error as NSError {
      NSLog("HabitManager.handleNotification failed: \(error.localizedDescription)")
    }
  }
  
  static var overdue: Int {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due < %@", Entry.State.Todo.rawValue, NSDate())
      let result = try HabitApp.moContext.executeFetchRequest(request)
      return result.count
    } catch let error as NSError {
      NSLog("HabitManager.overdue failed: \(error.localizedDescription)")
      return 0
    }
  }
  
  static func complete(index: Int) {
    do {
      let entry = current.removeAtIndex(index)
      entry.complete()
      try HabitApp.moContext.save()
    } catch let error {
      NSLog("HabitManager.complete failed: \(error)")
    }
  }
  
  static func skip(index: Int) {
    do {
      let entry = current.removeAtIndex(index)
      entry.skip()
      try HabitApp.moContext.save()
    } catch let error {
      NSLog("HabitManager.skip failed: \(error)")
    }
  }
  
  static func skip(habit: Habit? = nil) -> [NSIndexPath] {
    do {
      let before = NSDate(timeIntervalSinceNow: HabitApp.autoSkipDelayTimeInterval)
      var rows: [NSIndexPath] = []
      var newCurrent: [Entry] = []
      for (index, entry) in current.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(before) == .OrderedAscending {
          entry.skip()
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newCurrent.append(entry)
        }
      }
      current = newCurrent
      try HabitApp.moContext.save()
      return rows
    } catch let error {
      NSLog("HabitManager.skip failed: \(error)")
      return []
    }
  }
  
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
  
  static func delete(habit: Habit) -> [NSIndexPath] {
    do {
      var rows: [NSIndexPath] = []
      var newCurrent: [Entry] = []
      for (index, entry) in current.enumerate() {
        if entry.habit! == habit {
          rows.append(NSIndexPath(forItem: index, inSection: 0))
          removeNotification(entry)
        } else {
          newCurrent.append(entry)
        }
      }
      current = newCurrent
      var newUpcoming: [Entry] = []
      for (index, entry) in upcoming.enumerate() {
        if entry.habit! == habit {
          rows.append(NSIndexPath(forItem: index, inSection: 1))
          removeNotification(entry)
        } else {
          newUpcoming.append(entry)
        }
      }
      upcoming = newUpcoming
      HabitApp.moContext.deleteObject(habit)
      try HabitApp.moContext.save()
      return rows
    } catch let error as NSError {
      NSLog("HabitManager.delete failed: \(error.localizedDescription)")
      return []
    }
  }
  
  static func exists(name: String) -> Bool {
    do {
      let request = NSFetchRequest(entityName: "Habit")
      request.predicate = NSPredicate(format: "name ==[c] %@", name)
      if let _ = try HabitApp.moContext.executeFetchRequest(request).first {
        return true
      } else {
        return false
      }
    } catch let error as NSError {
      NSLog("HabitManager.exists failed: \(error.localizedDescription)")
      return true
    }
  }
  
  static func deleteEntries(after date: NSDate, habit: Habit? = nil, save: Bool = false) -> [NSIndexPath] {
    do {
      var rows: [NSIndexPath] = []
      var newCurrent: [Entry] = []
      for (index, entry) in current.enumerate() {
        if (habit == nil || entry.habit == habit) && entry.due!.compare(date) == .OrderedDescending {
          HabitApp.moContext.deleteObject(entry)
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newCurrent.append(entry)
        }
      }
      current = newCurrent
      var newUpcoming: [Entry] = []
      for (index, entry) in upcoming.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(date) == .OrderedDescending {
          HabitApp.moContext.deleteObject(entry)
          if HabitApp.upcoming {
            rows.append(NSIndexPath(forRow: index, inSection: 1))
          }
        } else {
          newUpcoming.append(entry)
        }
      }
      upcoming = newUpcoming
      if habit == nil {
        let habitRequest = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
        for habit in habits {
          habit.recalculateHistory(onDate: date)
        }
      } else {
        habit!.recalculateHistory(onDate: date)
      }
      if save { try HabitApp.moContext.save() }
      return rows
    } catch let error as NSError {
      NSLog("HabitManager.deleteEntries failed: \(error.localizedDescription)")
      return []
    }
  }
  
  static func createEntries(after date: NSDate, habit: Habit? = nil, save: Bool = true) -> [NSIndexPath] {
    do {
      if habit == nil {
        let habitRequest = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
        for habit in habits {
          habit.update(date, currentDate: NSDate())
        }
      } else {
        habit!.update(date, currentDate: NSDate())
      }
      if save { try HabitApp.moContext.save() }
      // TODO: does fetch hit memory or actual file storage?
      reload()
      
      var rows: [NSIndexPath] = []
      for (index, entry) in current.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(date) == .OrderedDescending {
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        }
      }
      if HabitApp.upcoming {
        for (index, entry) in upcoming.enumerate() {
          if (habit == nil || entry.habit! == habit) && entry.due!.compare(date) == .OrderedDescending {
            rows.append(NSIndexPath(forRow: index, inSection: 1))
          }
        }
      }
      return rows
    } catch let error as NSError {
      NSLog("HabitManager.createEntries failed: \(error.localizedDescription)")
      return []
    }
  }
  
}
