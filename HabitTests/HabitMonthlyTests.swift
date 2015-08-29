//
//  HabitMonthlyTests.swift
//  Habit
//
//  Created by harry on 8/2/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import XCTest
import CoreData
import Nimble

@testable import Habit

class HabitMonthlyTests: XCTestCase {
    
  var context: NSManagedObjectContext?
  
  override func setUp() {
    super.setUp()
    context = HabitApp.setUpInMemoryManagedObjectContext()
  }
  
  override func tearDown() {
    super.tearDown()
    context = nil
  }
  
  func testCountBeforeCreatedMonthly() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: createdAt)
    
    expect(habitTimes.countBeforeCreatedAt(createdAt)) == 2
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habitParts.partsOfMonth = [.Beginning, .End]
    
    expect(habitParts.countBeforeCreatedAt(createdAt)) == 1
    expect(habitParts.firstTodo).to(beNil())
  }
  
  func testDateRange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 10
    let now = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: now)
    var (start, end) = habit.dateRange(now)
    components.day = 1
    expect(start) == calendar.dateFromComponents(components)
    components.month = 9
    expect(end) == calendar.dateFromComponents(components)
    components.month = 10
    (start, end) = habit.dateRange(calendar.dateFromComponents(components)!)
    components.month = 9
    components.day = 1
    expect(start) == calendar.dateFromComponents(components)
    components.month = 10
    expect(end) == calendar.dateFromComponents(components)
  }
  
  func testOneTimeAMonth() {
    let calendar = HabitApp.calendar
    let createdAt = NSDate()
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 1, createdAt: createdAt)
    let now = calendar.dateByAddingUnit(.Hour, value: 1, toDate: createdAt)!
    habit.update(now)
    let nextMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: now)!
    expect(habit.totalCount()) == 2
    expect(habit.totalCount(nextMonth)) == 1
    let components = calendar.components([.Year, .Month, .Day], fromDate: nextMonth)
    components.day = 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month += 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesSkipBefore() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: createdAt)
    components.month = 5
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now).count) == 3 + 5 + 2
    expect(habit.skippedCount()) == 10
    components.month = 5
    components.day = 3 * 31 / 5 + 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsSkipBefore() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    components.month = 5
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now).count) == 1 + 2 + 1
    expect(habit.skippedCount()) == 4
    components.month = 6
    components.day = 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testEntriesOnMonth() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    components.month = 7
    habit.update(calendar.dateFromComponents(components)!)
    components.month = 5
    expect(habit.entriesOnDate(calendar.dateFromComponents(components)!).count) == 4
  }
  
  func testUpdateHistory() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    components.month = 7
    habit.update(calendar.dateFromComponents(components)!)
    
    let history = (habit.histories!.array as! [History])[1]
    expect(history.completed) == 0
    expect(history.skipped) == 0
    let entries = habit.entriesOnDate(history.date!)
    entries[0].complete()
    entries[1].complete()
    entries[2].skip()
    entries[3].complete()
    expect(history.completed) == 3
    expect(history.skipped) == 1
  }
  
  func testTimes2MonthsAgo() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    components.month = 5
    components.day = 5
    let today = calendar.dateFromComponents(components)!
    habit.update(today)
    
    expect(habit.totalCount(today)) == 2 + 4 + 0
    expect(habit.totalCount()) == 2 + 4 + 4 + 4
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today).count) == 6
    expect(habit.skippedCount()) == 6
    components.day = 31 / 4 + 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testParts2MonthsAgo() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    components.month = 5
    components.day = 5
    let today = calendar.dateFromComponents(components)!
    habit.update(today)
    
    expect(habit.totalCount(today)) == 1 + 2 + 0
    expect(habit.totalCount()) == 1 + 2 + 2 + 2
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today).count) == 3
    expect(habit.skippedCount()) == 3
    components.day = 31 / 3 + 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesCompletion() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.day = 3
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.day = 20
      var now = calendar.dateFromComponents(components)!
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      components.day = 3 * 31 / 4 + 1
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.month = 5
      components.day = 1
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
      entries[2].skip()
      entries[3].complete()
      components.month = 4
      components.day = 5
      now = calendar.dateFromComponents(components)!
      expect(habit.totalCount(now)) == 4
      expect(habit.completedCount()) == 3
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 3 / 4.0
      components.day = 31 / 4 + 1
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.month = 5
      components.day = 1
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testPartsCompletion() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 5
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Middle, .End]
    components.day = 8
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.month = 4
      var now = calendar.dateFromComponents(components)!
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      components.day = 2 * 30 / 3 + 1
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.month = 5
      components.day = 1
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
      habit.update(now)
      entries[2].skip()
      entries[3].complete()
      components.month = 5
      components.day = 5
      now = calendar.dateFromComponents(components)!
      expect(habit.totalCount(now)) == 4
      expect(habit.completedCount()) == 3
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 3 / 4.0
      components.day = 2 * 30 / 3 + 1
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.month = 6
      components.day = 1
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
    
  func testTimesSkipAMonth() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3 // March
    components.day = 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.day = 3
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      entries[2].skip()
      entries[3].complete()
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
    components.month = 5 // May
    components.day = 9
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 3
    expect(habit.skippedCount()) == 1 + 4 + 1
    expect(habit.totalCount(now)) == 4 + 4 + 1
    expect(habit.progress(now)) == 3 / 9.0
    components.day = 2 * 31 / 4 + 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 4
    expect(histories[0].completed) == 3
    expect(histories[0].skipped) == 1
    expect(histories[1].completed) == 0
    expect(histories[1].skipped) == 4
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 1
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 0
  }
  
  func testPartsSkipAMonth() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 5
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Middle, .End]
    components.day = 8
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      entries[2].skip()
      entries[3].complete()
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
    components.month = 6
    components.day = 25
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 3
    expect(habit.skippedCount()) == 0 + 1 + 2 + 1
    expect(habit.totalCount(now)) == 2 + 2 + 2 + 1
    expect(habit.progress(now)) == 3 / 7.0
    components.month = 7
    components.day = 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 8
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 5
    expect(histories[0].completed) == 2
    expect(histories[0].skipped) == 0
    expect(histories[1].completed) == 1
    expect(histories[1].skipped) == 1
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 2
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 1
    expect(histories[4].completed) == 0
    expect(histories[4].skipped) == 0
  }
  
}
