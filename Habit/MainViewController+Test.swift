//
//  MainViewController+Test.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

extension MainViewController {
    
  func testData() {
    do {
      let calendar = HabitApp.calendar
      //      var date = calendar.dateByAddingUnit(.WeekOfYear, value: -40, toDate: NSDate())!
      //      var h = Habit(context: HabitApp.moContext, name: "5. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: date)
      //      h.update(NSDate())
      //      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
      //        //print(formatter.stringFromDate(date))
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
      //        date = NSDate(timeInterval: 24 * 3600 * 7, sinceDate: date)
      //      }
      //      date = calendar.dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate())!
      //      h = Habit(context: HabitApp.moContext, name: "W: Will not show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
      //      h.update(NSDate())
      //      date = calendar.dateByAddingUnit(.WeekOfYear, value: -5, toDate: NSDate())!
      //      h = Habit(context: HabitApp.moContext, name: "W: Will show skip dialog", details: "", frequency: .Weekly, times: 0, createdAt: date)
      //      h.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Friday, .Saturday]
      //      date = calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date)!
      //      h.update(date)
      //      h.deleteEntries(after: date)
      //      HabitApp.moContext.refreshAllObjects()
      //      h.pausedBool = true
      //      date = calendar.dateByAddingUnit(.WeekOfYear, value: 2, toDate: date)!
      //      h.update(date)
      //      h.pausedBool = false
      //      h.generateEntries(after: date)
      //      h.update(NSDate())
      
      var date = calendar.dateByAddingUnit(.Day, value: -180, toDate: NSDate())!
      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: date)
      h.update(NSDate())
      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
        let entries = h.entriesOnDate(date)
        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
          entries[i].complete()
        }
        for entry in entries {
          if entry.state == .Todo {
            entry.skip()
          }
        }
        date = NSDate(timeInterval: Double(Constants.daySec), sinceDate: date)
      }
      
      //      let createdAt = calendar.dateByAddingUnit(.Hour, value: 10, toDate: calendar.zeroTime(calendar.dateByAddingUnit(.Day, value: -5, toDate: NSDate())!))!
      //      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
      //      h.update(NSDate())
      //      h.pausedBool = true
      //      var date = calendar.dateByAddingUnit(.Day, value: 1, toDate: createdAt)!
      //      HabitManager.reload()
      //      HabitManager.deleteEntries(after: date, habit: h)
      //      HabitApp.moContext.refreshAllObjects()
      //      date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
      //      h.update(date)
      //      h.pausedBool = false
      //      date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
      //      h.update(date, currentDate: NSDate())
      //      date = createdAt
      //      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Day) {
      //        let entries = h.entriesOnDate(date)
      //        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
      //          entries[i].complete()
      //        }
      //        for entry in entries {
      //          if entry.state == .Todo {
      //            entry.skip()
      //          }
      //        }
      //        date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
      //      }
      
      //      date = calendar.dateByAddingUnit(.Day, value: -25, toDate: NSDate())!
      //      h = Habit(context: HabitApp.moContext, name: "Daily with pause", details: "", frequency: .Daily, times: 12, createdAt: date)
      //      date = calendar.dateByAddingUnit(.Day, value: 4, toDate: date)!
      //      h.update(date)
      //      h.deleteEntries(after: date)
      //      HabitApp.moContext.refreshAllObjects()
      //      h.pausedBool = true
      //      date = calendar.dateByAddingUnit(.Day, value: 7, toDate: date)!
      //      h.update(date)
      //      h.pausedBool = false
      //      h.generateEntries(after: date)
      //      h.update(NSDate())
      
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
