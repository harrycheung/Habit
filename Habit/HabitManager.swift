//
//  HabitManager.swift
//  Habit
//
//  Created by harry on 9/28/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import CoreData

class HabitManager {
  
  private var today = [Entry]()
  private var tomorrow = [Entry]()
  private var habits = [Habit]()
  
  private static var instance: HabitManager = {
    return HabitManager()
    }()
  
  static var today: [Entry] {
    get { return HabitManager.instance.today }
    set { HabitManager.instance.today = newValue }
  }
  
  static var todayCount: Int {
    return HabitManager.instance.today.count
  }
  
  static var tomorrow: [Entry] {
    get { return HabitManager.instance.tomorrow }
    set { HabitManager.instance.tomorrow = newValue }
  }
  
  static var tomorrowCount: Int {
    return HabitManager.instance.tomorrow.count
  }
  
  static var habits: [Habit] {
    return HabitManager.instance.habits
  }
  
  static var habitCount: Int {
    return HabitManager.instance.habits.count
  }
  
  static func reload() {
    reload(NSDate())
  }
  
  static func reload(now: NSDate) {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due <= %@", Entry.State.Todo.rawValue, now)
      instance.today = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort()
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@", Entry.State.Todo.rawValue, now)
      instance.tomorrow = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort()
      let habitRequest = NSFetchRequest(entityName: "Habit")
      habitRequest.predicate = NSPredicate(format: "name != ''")
      instance.habits = (try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit])
    } catch let error as NSError {
      NSLog("HabitManager.reload failed: \(error.localizedDescription)")
    }
  }
  
  static func updateNotifications() {
    if HabitApp.notification {
      HabitApp.initNotification()
      UIApplication.sharedApplication().cancelAllLocalNotifications()
      var count = 0
      var number = 1
      let now = NSDate()
      for entry in (instance.today + instance.tomorrow).sort() {
        if count > 64 {
          break
        }
        if entry.habit!.notifyBool && entry.due!.compare(now) == .OrderedDescending {
          addNotification(entry, number: number)
          count += 1
        }
        number += 1
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
      let index = instance.today.indexOf(entry)!
      switch (identifier) {
      case "COMPLETE":
        // TODO: NOT RIGHT
        complete(index, today: true)
      case "SKIP":
        skip(index, today: true)
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
  
  static func complete(index: Int, today: Bool) {
    do {
      let entry = today ? instance.today.removeAtIndex(index) : instance.tomorrow.removeAtIndex(index)
      let notFake = !entry.habit!.isFake
      entry.complete()
      try HabitApp.moContext.save()
      if notFake {
        updateNotifications()
      }
    } catch let error {
      NSLog("HabitManager.complete failed: \(error)")
    }
  }
  
  static func skip(index: Int, today: Bool) {
    do {
      let entry = today ? instance.today.removeAtIndex(index) : instance.tomorrow.removeAtIndex(index)
      let notFake = !entry.habit!.isFake
      entry.skip()
      try HabitApp.moContext.save()
      if notFake {
        updateNotifications()
      }
    } catch let error {
      NSLog("HabitManager.skip failed: \(error)")
    }
  }
  
  static func skip(habit: Habit? = nil) -> [NSIndexPath] {
    do {
      let before = NSDate(timeIntervalSinceNow: HabitApp.autoSkipDelayTimeInterval)
      var rows: [NSIndexPath] = []
      var newToday: [Entry] = []
      for (index, entry) in instance.today.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(before) == .OrderedAscending {
          entry.skip()
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newToday.append(entry)
        }
      }
      instance.today = newToday
      try HabitApp.moContext.save()
      updateNotifications()
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
        if !habit.isFake {
          habit.update(now)
          if HabitApp.autoSkip && !habit.neverAutoSkipBool {
            habit.skip(before: NSDate(timeInterval: HabitApp.autoSkipDelayTimeInterval, sinceDate: now))
          }
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
      var newToday: [Entry] = []
      for (index, entry) in instance.today.enumerate() {
        if entry.habit! == habit {
          rows.append(NSIndexPath(forItem: index, inSection: 0))
        } else {
          newToday.append(entry)
        }
      }
      instance.today = newToday
      var newTomorrow: [Entry] = []
      for (index, entry) in instance.tomorrow.enumerate() {
        if entry.habit! == habit {
          rows.append(NSIndexPath(forItem: index, inSection: 1))
        } else {
          newTomorrow.append(entry)
        }
      }
      instance.tomorrow = newTomorrow
      HabitApp.moContext.deleteObject(habit)
      try HabitApp.moContext.save()
      updateNotifications()
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
      var newToday: [Entry] = []
      for (index, entry) in instance.today.enumerate() {
        if (habit == nil || entry.habit == habit) && entry.due!.compare(date) == .OrderedDescending {
          HabitApp.moContext.deleteObject(entry)
          rows.append(NSIndexPath(forRow: index, inSection: 0))
        } else {
          newToday.append(entry)
        }
      }
      instance.today = newToday
      var newTomorrow: [Entry] = []
      for (index, entry) in instance.tomorrow.enumerate() {
        if (habit == nil || entry.habit! == habit) && entry.due!.compare(date) == .OrderedDescending {
          HabitApp.moContext.deleteObject(entry)
          rows.append(NSIndexPath(forRow: index, inSection: 1))
        } else {
          newTomorrow.append(entry)
        }
      }
      instance.tomorrow = newTomorrow
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
      updateNotifications()
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
        
        if habit!.isNew {
          HabitManager.instance.habits.append(habit!)
        }
      }
      if save { try HabitApp.moContext.save() }
      
      var rows: [NSIndexPath] = []
      var newToday: [Entry] = []
      var newTomorrow: [Entry] = []
      var index = 0
      var switchedTotomorrow = false
      for entry in entries {
        if HabitApp.calendar.isDateInToday(entry.due!) {
          while !instance.today.isEmpty {
            if entry < instance.today[0] {
              rows.append(NSIndexPath(forRow: index, inSection: 0))
              newToday.append(entry)
              index += 1
              break
            } else {
              newToday.append(instance.today.removeAtIndex(0))
              index += 1
            }
          }
          if instance.today.isEmpty {
            rows.append(NSIndexPath(forRow: index, inSection: 0))
            newToday.append(entry)
            index += 1
          }
        } else {
          if !switchedTotomorrow {
            index = 0
            switchedTotomorrow = true
          }
          while !instance.tomorrow.isEmpty {
            if entry < instance.tomorrow[0] {
              rows.append(NSIndexPath(forRow: index, inSection: 0))
              newTomorrow.append(entry)
              index += 1
              break
            } else {
              newTomorrow.append(instance.tomorrow.removeAtIndex(0))
              index += 1
            }
          }
          if instance.tomorrow.isEmpty {
            rows.append(NSIndexPath(forRow: index, inSection: 0))
            newTomorrow.append(entry)
            index += 1
          }
        }
      }
      instance.today = newToday + instance.today
      instance.tomorrow = newTomorrow + instance.tomorrow
      updateNotifications()
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
    let rows: [NSIndexPath] = []
//    for (index, entry) in instance.today.enumerate() {
//      if entry.habit! == habit {
//        rows.append(NSIndexPath(forRow: index, inSection: 0))
//      }
//    }
//    if HabitApp.tomorrow {
//      for (index, entry) in instance.tomorrow.enumerate() {
//        if entry.habit! == habit {
//          rows.append(NSIndexPath(forRow: index, inSection: 1))
//        }
//      }
//    }
    return rows
  }
  
//  static func pause(habit: Habit) -> [NSIndexPath] {
//    instance.paused.append(habit)
//    return HabitApp.tomorrow ? [NSIndexPath(forRow: instance.paused.count - 1, inSection: 2)] : []
//  }
//  
//  static func unpause(habit:Habit) -> [NSIndexPath] {
//    let index = instance.paused.indexOf(habit)!
//    instance.paused.removeAtIndex(index)
//    return HabitApp.tomorrow ? [NSIndexPath(forRow: index, inSection: 2)] : []
//  }
  
  static var FakeEntries = [
    "Welcome to habit",
    "Swipe right to complete",
    "Swipe left to skip",
    "Tap to view history"
  ]
  
  static func createFirstEntries() {
    let createdAt = HabitApp.calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate())!
    let habit = Habit(context: HabitApp.moContext, name: "", details: "", frequency: .Daily, times: 10, createdAt: createdAt)
    var dateIterator = HabitApp.calendar.dateByAddingUnit(.Minute, value: -1, toDate: NSDate())!
    let day = HabitApp.calendar.components([.Day], fromDate: dateIterator).day
    for i in 0..<FakeEntries.count {
      dateIterator = dateIterator.dateByAddingTimeInterval(Double(i))
      let _ = Entry(context: HabitApp.moContext, habit: habit, due: dateIterator, period: day, number: i)
    }
    
    dateIterator = HabitApp.calendar.dateByAddingUnit(.Day, value: -120, toDate: NSDate())!
    for _ in 0..<120 {
      let completed = Int(arc4random_uniform(UInt32(10)))
      habit.updateHistory(onDate: dateIterator, completedBy: completed, skippedBy: 10 - completed, totalBy: 10)
      dateIterator = HabitApp.calendar.dateByAddingUnit(.Day, value: 1, toDate: dateIterator)!
    }
    habit.currentStreak = 8
    habit.longestStreak = 27
    save()
  }
  
}
