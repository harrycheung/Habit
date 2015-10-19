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
  private var paused = [Habit]()
  
  private static var instance: HabitManager = {
    return HabitManager()
    }()
  
  static var current: [Entry] {
    get { return HabitManager.instance.current }
    set { HabitManager.instance.current = newValue }
  }
  
  static var currentCount: Int {
    return HabitManager.instance.current.count
  }
  
  static var upcoming: [Entry] {
    get { return HabitManager.instance.upcoming }
    set { HabitManager.instance.upcoming = newValue }
  }
  
  static var upcomingCount: Int {
    return HabitManager.instance.upcoming.count
  }
  
  static var paused: [Habit] {
    return HabitManager.instance.paused
  }
  
  static var pausedCount: Int {
    return HabitManager.instance.paused.count
  }
  
  static func reload() {
    reload(NSDate())
  }
  
  static func reload(now: NSDate) {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND (due <= %@ || (due > %@ AND period IN %@))",
        Entry.State.Todo.rawValue, now, now, HabitApp.currentPeriods(now))
      instance.current = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort()
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)",
        Entry.State.Todo.rawValue, now, HabitApp.currentPeriods(now))
      instance.upcoming = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort()
      let pausedRequest = NSFetchRequest(entityName: "Habit")
      pausedRequest.predicate = NSPredicate(format: "paused == YES")
      instance.paused = (try HabitApp.moContext.executeFetchRequest(pausedRequest) as! [Habit])
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
      for entry in instance.current {
        if count > 64 {
          break
        }
        if entry.habit!.notifyBool && entry.due!.compare(now) == .OrderedDescending {
          addNotification(entry, number: number)
          count++
        }
        number++
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
      let index = instance.current.indexOf(entry)!
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
      let entry = instance.current.removeAtIndex(index)
      entry.complete()
      try HabitApp.moContext.save()
    } catch let error {
      NSLog("HabitManager.complete failed: \(error)")
    }
  }
  
  static func skip(index: Int) {
    do {
      let entry = instance.current.removeAtIndex(index)
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
      for (index, entry) in instance.current.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(before) == .OrderedAscending {
          entry.skip()
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newCurrent.append(entry)
        }
      }
      instance.current = newCurrent
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
      for (index, entry) in instance.current.enumerate() {
        if entry.habit! == habit {
          removeNotification(entry)
          rows.append(NSIndexPath(forItem: index, inSection: 0))
        } else {
          newCurrent.append(entry)
        }
      }
      instance.current = newCurrent
      var newUpcoming: [Entry] = []
      for (index, entry) in instance.upcoming.enumerate() {
        if entry.habit! == habit {
          removeNotification(entry)
          if HabitApp.upcoming {
            rows.append(NSIndexPath(forItem: index, inSection: 1))
          }
        } else {
          newUpcoming.append(entry)
        }
      }
      instance.upcoming = newUpcoming
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
      for (index, entry) in instance.current.enumerate() {
        if (habit == nil || entry.habit == habit) && entry.due!.compare(date) == .OrderedDescending {
          removeNotification(entry)
          HabitApp.moContext.deleteObject(entry)
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newCurrent.append(entry)
        }
      }
      instance.current = newCurrent
      var newUpcoming: [Entry] = []
      for (index, entry) in instance.upcoming.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(date) == .OrderedDescending {
          removeNotification(entry)
          HabitApp.moContext.deleteObject(entry)
          if HabitApp.upcoming {
            rows.append(NSIndexPath(forRow: index, inSection: 1))
          }
        } else {
          newUpcoming.append(entry)
        }
      }
      instance.upcoming = newUpcoming
      if habit == nil {
        let habitRequest = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
        for habit in habits {
          habit.clearHistory(after: date)
        }
      } else {
        habit!.clearHistory(after: date)
      }
      if save { try HabitApp.moContext.save() }
      return rows
    } catch let error as NSError {
      NSLog("HabitManager.deleteEntries failed: \(error.localizedDescription)")
      return []
    }
  }
  
  static func createEntries(after date: NSDate, currentDate: NSDate, habit: Habit? = nil, save: Bool = false) -> [NSIndexPath] {
    do {
      var entries: [Entry] = []
      if habit == nil {
        let habitRequest = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
        for habit in habits {
          entries += habit.update(date, currentDate: currentDate)
        }
      } else {
        entries += habit!.update(date, currentDate: currentDate)
      }
      if save { try HabitApp.moContext.save() }
      
      var rows: [NSIndexPath] = []
      var newCurrent: [Entry] = []
      var newUpcoming: [Entry] = []
      var index = 0
      let currentPeriods = HabitApp.currentPeriods()
      var switchedToUpcoming = false
      for entry in entries {
        if currentPeriods.contains(entry.period!) {
          while !instance.current.isEmpty {
            if entry < instance.current[0] {
              rows.append(NSIndexPath(forRow: index, inSection: 0))
              newCurrent.append(entry)
              index++
              break
            } else {
              newCurrent.append(instance.current.removeAtIndex(0))
              index++
            }
          }
          if instance.current.isEmpty {
            rows.append(NSIndexPath(forRow: index, inSection: 0))
            newCurrent.append(entry)
            index++
          }
        } else {
          if !switchedToUpcoming {
            index = 0
            switchedToUpcoming = true
          }
          while !instance.upcoming.isEmpty {
            if entry < instance.upcoming[0] {
              if HabitApp.upcoming {
                rows.append(NSIndexPath(forRow: index, inSection: 1))
              }
              newUpcoming.append(entry)
              index++
              break
            } else {
              newUpcoming.append(instance.upcoming.removeAtIndex(0))
              index++
            }
          }
          if instance.upcoming.isEmpty {
            if HabitApp.upcoming {
              rows.append(NSIndexPath(forRow: index, inSection: 1))
            }
            newUpcoming.append(entry)
            index++
          }
        }
      }
      instance.current = newCurrent + instance.current
      instance.upcoming = newUpcoming + instance.upcoming

      return rows
    } catch let error as NSError {
      NSLog("HabitManager.createEntries failed: \(error.localizedDescription)")
      return []
    }
  }
  
  static func save() {
    do {
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("HabitManager.save failed: \(error.localizedDescription)")
    }
  }
  
  static func rows(habit: Habit) -> [NSIndexPath] {
    var rows: [NSIndexPath] = []
    for (index, entry) in instance.current.enumerate() {
      if entry.habit! == habit {
        rows.append(NSIndexPath(forRow: index, inSection: 0))
      }
    }
    if HabitApp.upcoming {
      for (index, entry) in instance.upcoming.enumerate() {
        if entry.habit! == habit {
          rows.append(NSIndexPath(forRow: index, inSection: 1))
        }
      }
    }
    return rows
  }
  
  static func pause(habit: Habit) -> [NSIndexPath] {
    instance.paused.append(habit)
    return HabitApp.upcoming ? [NSIndexPath(forRow: instance.paused.count - 1, inSection: 2)] : []
  }
  
  static func unpause(habit:Habit) -> [NSIndexPath] {
    let index = instance.paused.indexOf(habit)!
    instance.paused.removeAtIndex(index)
    return HabitApp.upcoming ? [NSIndexPath(forRow: index, inSection: 2)] : []
  }
  
}
