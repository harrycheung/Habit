//
//  HabitManager.swift
//  Habit
//
//  Created by harry on 9/28/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import CoreData
import UIKit
import UserNotifications

class HabitManager {

  private var habits = [Habit]()
  private var today = [History]()
  
  private static var instance: HabitManager = {
    return HabitManager()
  }()
  
  static var habits: [Habit] {
    return HabitManager.instance.habits
  }
  
  static var habitCount: Int {
    return HabitManager.instance.habits.count
  }
  
  static func reload() {
    reload(now: Date())
  }
  
  static func reload(now: Date) {
    do {
      let calendar = HabitApp.calendar
      var oneDay = DateComponents()
      oneDay.day = 1
      let today = calendar.zeroTime(date: calendar.date(byAdding: oneDay, to: now)!)
      let request: NSFetchRequest<NSFetchRequestResult> = History.fetchRequest()
      request.predicate = NSPredicate(format: "date == %@", today as CVarArg)
      instance.today = try HabitApp.moContext.fetch(request) as! [History]
      let habitRequest: NSFetchRequest<NSFetchRequestResult> = Habit.fetchRequest()
      instance.habits = try HabitApp.moContext.fetch(habitRequest) as! [Habit]
    } catch let error as NSError {
      NSLog("HabitManager.reload failed: \(error.localizedDescription)")
    }
  }
  
  static func updateNotifications() {
//    if HabitApp.notification {
//      HabitApp.initNotification()
//      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//      var count = 0
//      var number = 1
//      let now = Date()
//      for entry in (instance.today + instance.upcoming).sorted(by: { $0.due! < $1.due! }) {
//        if count > 64 {
//          break
//        }
//        if entry.habit!.notify && entry.due! > now {
//          addNotification(entry: entry, number: number)
//          count += 1
//        }
//        number += 1
//      }
//    }
  }
  
//  private static func addNotification(entry: Entry, number: Int) {
//    if HabitApp.notification {
//      UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//        if settings.alertSetting == .enabled {
//          let content = UNMutableNotificationContent()
//          content.title = "Habit"
//          content.body = entry.habit!.name!
//          content.sound = UNNotificationSound.default()
//          content.badge = NSNumber(value: number)
//          content.categoryIdentifier = "HABIT_CATEGORY"
//          let due = NSCalendar.current.dateComponents(in: .current, from: entry.due!)
//          let trigger = UNCalendarNotificationTrigger(dateMatching: due, repeats: false)
//          let request = UNNotificationRequest(identifier: entry.objectID.uriRepresentation().absoluteString,
//                                              content: content,
//                                              trigger: trigger)
//          UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
////            if let error = error {
////              // Something went wrong
////            }
//          })
//        }
//      }
//    }
//  }
  
//  static func removeNotification(entry: Entry) {
//    if HabitApp.notification {
//      UNUserNotificationCenter.current().removePendingNotificationRequests(
//        withIdentifiers: [entry.objectID.uriRepresentation().absoluteString])
//    }
//  }
  
  static func handleNotification(notification: UNNotification, identifier: String) {
//    do {
//      let entryURL = URL(string: notification.request.identifier)!
//      let entryID = HabitApp.moContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: entryURL)!
//      let entry = try HabitApp.moContext.existingObject(with: entryID) as! Entry
//      let index = instance.today.index(of: entry)!
//      switch (identifier) {
//      case "COMPLETE":
//        // TODO: NOT RIGHT
//        complete(index: index, today: true)
//      case "SKIP":
//        skip(index: index, today: true)
//      default:
//        return
//      }
//      UIApplication.shared.applicationIconBadgeNumber = HabitManager.overdue
//      updateNotifications()
//    } catch let error as NSError {
//      NSLog("HabitManager.handleNotification failed: \(error.localizedDescription)")
//    }
  }
  
  
  static func complete(index: Int, today: Bool) {
//    do {
//      let entry = today ? instance.today.remove(at: index) : instance.upcoming.remove(at: index)
//      let notFake = !entry.habit!.isFake
//      entry.complete()
//      try HabitApp.moContext.save()
//      if notFake {
//        updateNotifications()
//      }
//    } catch let error {
//      NSLog("HabitManager.complete failed: \(error)")
//    }
  }
  
  static func skip(index: Int, today: Bool) {
//    do {
//      let entry = today ? instance.today.remove(at: index) : instance.upcoming.remove(at: index)
//      let notFake = !entry.habit!.isFake
//      entry.skip()
//      try HabitApp.moContext.save()
//      if notFake {
//        updateNotifications()
//      }
//    } catch let error {
//      NSLog("HabitManager.skip failed: \(error)")
//    }
  }
  
  static func updateHabits() {
    do {
      let now = Date()
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Habit")
      let habits = try HabitApp.moContext.fetch(request) as! [Habit]
      for habit in habits {
        if !habit.isFake {
          _ = habit.update(currentDate: now)
//          if HabitApp.autoSkip && !habit.neverAutoSkip {
//            _ = habit.skip(before: Date(timeInterval: HabitApp.autoSkipDelayTimeInterval, since: now))
//          }
        }
      }
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("HabitManager.updateHabits failed: \(error.localizedDescription)")
    }
  }
  
  static func exists(name: String) -> Bool {
    do {
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Habit")
      request.predicate = NSPredicate(format: "name ==[c] %@", name)
      if let _ = try HabitApp.moContext.fetch(request).first {
        return true
      } else {
        return false
      }
    } catch let error as NSError {
      NSLog("HabitManager.exists failed: \(error.localizedDescription)")
      return true
    }
  }
  
  static func save() {
    do {
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("HabitManager.save failed: \(error.localizedDescription)")
    }
  }
  
  static func rows(habit: Habit) -> [IndexPath] {
    let rows: [IndexPath] = []
//    for (index, entry) in instance.today.enumerated() {
//      if entry.habit! == habit {
//        rows.append(IndexPath(row: forRow: index, inSection: 0, section: index))
//      }
//    }
//    if HabitApp.upcoming {
//      for (index, entry) in instance.upcoming.enumerated() {
//        if entry.habit! == habit {
//          rows.append(IndexPath(row: forRow: index, inSection: 1, section: index))
//        }
//      }
//    }
    return rows
  }
  
//  static func pause(habit: Habit) -> [IndexPath] {
//    instance.paused.append(habit)
//    return HabitApp.upcoming ? [IndexPath(forRow: instance.paused.count - 1, inSection: 2)] : []
//  }
//  
//  static func unpause(habit:Habit) -> [IndexPath] {
//    let index = instance.paused.indexOf(habit)!
//    instance.paused.removeAtIndex(index)
//    return HabitApp.upcoming ? [IndexPath(row: forRow: index, inSection: 2, section: index)] : []
//  }
  
  static var FakeEntries = [
    "Welcome to habit",
    "Swipe right to complete",
    "Swipe left to skip",
    "Tap to view history"
  ]
  
  static func createFirstEntries() {
//    var threeMonthsBack = DateComponents()
//    threeMonthsBack.day = -120
//    let createdAt = HabitApp.calendar.date(byAdding: threeMonthsBack, to: Date())!
//    let habit = Habit(context: HabitApp.moContext, name: "", details: "", frequency: .Daily, times: 10, createdAt: createdAt)
//    var oneMinuteAgo = DateComponents()
//    oneMinuteAgo.minute = -1
//    var dateIterator = HabitApp.calendar.date(byAdding: oneMinuteAgo, to: Date())!
//    let day = HabitApp.calendar.components([.day], from: dateIterator).day
//    for i in 0..<FakeEntries.count {
//      dateIterator = dateIterator.addingTimeInterval(Double(i))
//      let _ = Entry(context: HabitApp.moContext, habit: habit, due: dateIterator, period: day!, number: i)
//    }
//    
//    var oneDayLater = DateComponents()
//    oneDayLater.day = 1
//    dateIterator = HabitApp.calendar.date(byAdding: threeMonthsBack, to: Date())!
//    for _ in 0..<120 {
//      let completed = Int(arc4random_uniform(UInt32(10)))
//      habit.updateHistory(onDate: dateIterator, completedBy: completed, skippedBy: 10 - completed, totalBy: 10)
//      dateIterator = HabitApp.calendar.date(byAdding: oneDayLater, to: dateIterator)!
//    }
//    habit.currentStreak = 8
//    habit.longestStreak = 27
    for i in 0..<FakeEntries.count {
      _ = Habit(context: HabitApp.moContext, name: FakeEntries[i], details: "", frequency: .Daily, times: 10, createdAt: Date())
    }
    save()
  }
  
}
