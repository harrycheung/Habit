//
//  MainViewController+Test.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

import UIKit

extension MainViewController {
    
  func testData() {
    do {
//      let calendar = HabitApp.calendar
      //      var date = calendar.date(byAdding: .weekOfYear, value: -40, toDate: Date())!
      //      var h = Habit(context: HabitApp.moContext, name: "5. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: date)
      //      h.update(Date())
      //      while !calendar.isDate(date, equalToDate: Date(), toUnitGranularity: .weekOfYear) {
      //        //print(formatter.string(from: date))
      //        let entries = h.entriesOnDate(date)
      //        //print("c: \(entries.count)")
      //        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
      //          entries[i].complete()
      //        }
      //        for entry in entries {
      //          if entry.state == .Todo {
      //            entry.skip()
      //          }
      //        }
      //        date = Date(timeInterval: 24 * 3600 * 7, sinceDate: date)
      //      }
      //      date = calendar.date(byAdding: .weekOfYear, value: -2, toDate: Date())!
      //      h = Habit(context: HabitApp.moContext, name: "W: Will not show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
      //      h.update(Date())
      //      date = calendar.date(byAdding: .weekOfYear, value: -5, toDate: Date())!
      //      h = Habit(context: HabitApp.moContext, name: "W: Will show skip dialog", details: "", frequency: .Weekly, times: 0, createdAt: date)
      //      h.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Friday, .Saturday]
      //      date = calendar.date(byAdding: .weekOfYear, value: 1, toDate: date)!
      //      h.update(date)
      //      h.deleteEntries(after: date)
      //      HabitApp.moContext.refreshAllObjects()
      //      h.paused = true
      //      date = calendar.date(byAdding: .weekOfYear, value: 2, toDate: date)!
      //      h.update(date)
      //      h.paused = false
      //      h.generateEntries(after: date)
      //      h.update(Date())
      
//      var sixMonthsAgo = DateComponents()
//      sixMonthsAgo.day = -180
//      var date = calendar.date(byAdding: sixMonthsAgo, to: Date())!
//      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: date)
//      _ = h.update(currentDate: Date())
//      while !calendar.isDate(date, equalTo: Date(), toUnitGranularity: .weekOfYear) {
//        let entries = h.entriesOnDate(date: date)
//        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
//          entries[i].complete()
//        }
//        for entry in entries {
//          if entry.state == .Todo {
//            entry.skip()
//          }
//        }
//        date = Date(timeInterval: Double(Constants.daySec), since: date)
//      }
      
      //      let createdAt = calendar.date(byAdding: .hour, value: 10, toDate: calendar.zeroTime(calendar.date(byAdding: .day, value: -5, toDate: Date())!))!
      //      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
      //      h.update(Date())
      //      h.paused = true
      //      var date = calendar.date(byAdding: .day, value: 1, toDate: createdAt)!
      //      HabitManager.reload()
      //      HabitManager.deleteEntries(after: date, habit: h)
      //      HabitApp.moContext.refreshAllObjects()
      //      date = calendar.date(byAdding: .day, value: 1, toDate: date)!
      //      h.update(date)
      //      h.paused = false
      //      date = calendar.date(byAdding: .day, value: 1, toDate: date)!
      //      h.update(date, currentDate: Date())
      //      date = createdAt
      //      while !calendar.isDate(date, equalToDate: Date(), toUnitGranularity: .day) {
      //        let entries = h.entriesOnDate(date)
      //        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
      //          entries[i].complete()
      //        }
      //        for entry in entries {
      //          if entry.state == .Todo {
      //            entry.skip()
      //          }
      //        }
      //        date = calendar.date(byAdding: .day, value: 1, toDate: date)!
      //      }
      
      //      date = calendar.date(byAdding: .day, value: -25, toDate: Date())!
      //      h = Habit(context: HabitApp.moContext, name: "Daily with pause", details: "", frequency: .Daily, times: 12, createdAt: date)
      //      date = calendar.date(byAdding: .day, value: 4, toDate: date)!
      //      h.update(date)
      //      h.deleteEntries(after: date)
      //      HabitApp.moContext.refreshAllObjects()
      //      h.paused = true
      //      date = calendar.date(byAdding: .day, value: 7, toDate: date)!
      //      h.update(date)
      //      h.paused = false
      //      h.generateEntries(after: date)
      //      h.update(Date())
      
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    HabitManager.reload()
    tableView.reloadData()
    HabitManager.updateNotifications()
  }
  
}
