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
  
  var previousStartOfDay: Int = 0
  var previousEndOfDay: Int = 0
  
  override func setUp() {
    super.setUp()
    
    previousStartOfDay = HabitApp.startOfDay
    previousEndOfDay = HabitApp.endOfDay
    
    HabitApp.setUpInMemoryManagedObjectContext()
    HabitApp.startOfDay = 0
    HabitApp.endOfDay = 24 * 60
  }
  
  override func tearDown() {
    HabitApp.startOfDay = previousStartOfDay
    HabitApp.endOfDay = previousEndOfDay
    
    super.tearDown()
  }
  
  func testCountBeforeCreatedMonthly() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habitTimes = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: createdAt)
    
    expect(habitTimes.countBefore(createdAt)) == 2
    components.month = 4
    components.day = 1
    expect(habitTimes.countBefore(calendar.dateFromComponents(components)!)) == 5
    
    let habitParts = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habitParts.partsOfMonth = [.Beginning, .End]
    
    expect(habitParts.countBefore(createdAt)) == 1
    components.month = 4
    components.day = 1
    expect(habitParts.countBefore(calendar.dateFromComponents(components)!)) == 2
    expect(habitParts.firstTodo).to(beNil())
  }
  
  func testDateRange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 10
    let now = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: now)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 1, createdAt: createdAt)
    let now = calendar.dateByAddingUnit(.Hour, value: 1, toDate: createdAt)!
    habit.update(now)
    let nextMonth = calendar.dateByAddingUnit(.Month, value: 1, toDate: now)!
    expect(habit.entries!.count) == 2
    expect(habit.entryCountBefore(nextMonth)) == 1
    let components = calendar.components([.Year, .Month, .Day], fromDate: nextMonth)
    components.day = 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month++
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesSkip() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 5, createdAt: createdAt)
    components.month = 5
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 3 + 5 + 2
    expect(habit.skipped!.integerValue) == 10
    components.month = 5
    components.day = 3 * 31 / 5 + 1
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 7
    components.day = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsSkip() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    components.month = 5
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 1 + 2 + 1
    expect(habit.skipped!.integerValue) == 4
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    components.month = 5
    components.day = 5
    let today = calendar.dateFromComponents(components)!
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 2 + 4 + 0
    expect(habit.entries!.count) == 2 + 4 + 4 + 4
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 6
    expect(habit.skipped!.integerValue) == 6
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    components.month = 5
    components.day = 5
    let today = calendar.dateFromComponents(components)!
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 1 + 2 + 0
    expect(habit.entries!.count) == 1 + 2 + 2 + 2
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 3
    expect(habit.skipped!.integerValue) == 3
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.day = 3
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.day = 20
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 0
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
      expect(habit.entryCountBefore(now)) == 4
      expect(habit.completed!.integerValue) == 3
      expect(habit.skipped!.integerValue) == 1
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Middle, .End]
    components.day = 8
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.month = 4
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 0
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
      expect(habit.entryCountBefore(now)) == 4
      expect(habit.completed!.integerValue) == 3
      expect(habit.skipped!.integerValue) == 1
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.day = 3
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
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
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 3
    expect(habit.skipped!.integerValue) == 1 + 4 + 1
    expect(habit.entryCountBefore(now)) == 4 + 4 + 1
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Middle, .End]
    components.day = 8
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
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
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 3
    expect(habit.skipped!.integerValue) == 0 + 1 + 2 + 1
    expect(habit.entryCountBefore(now)) == 2 + 2 + 2 + 1
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
  
  func testTimesCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 15 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 12
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 5
    components.month = 8
    components.day = 31
    components.hour = 15
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    components.month = 9
    components.day = 30
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)
    
    components.month = 8
    components.day = 31
    components.hour = 22
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 4, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 4
    components.month = 9
    components.day = 30 / 4
    components.hour = 15
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    components.day = 30
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)
  }
  
  func testPartsCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 19 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 12
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    habit.update(createdAt)
    expect(habit.entries!.count) == 3
    components.month = 8
    components.day = 31
    components.hour = 19
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    components.month = 9
    components.day = 30
    components.hour = 19
    expect(habit.lastEntry) == calendar.dateFromComponents(components)
    
    components.month = 8
    components.day = 31
    components.hour = 22
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 0, createdAt: createdAt)
    habit.partsOfMonth = [.Beginning, .End]
    habit.update(createdAt)
    components.month = 9
    components.day = 30 / 3
    components.hour = 19
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    expect(habit.entries!.count) == 2
  }
  
  func testFrequencyChange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 15
    components.hour = 12
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 3, createdAt: createdAt)
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 5
    
    (habit.entries!.objectAtIndex(0) as! Entry).complete()
    habit.times = 1
    let predicate = NSPredicate(format: "due > %@", calendar.dateFromComponents(components)!)
    let entriesToDelete = habit.entries!.filteredOrderedSetUsingPredicate(predicate).array as! [Entry]
    for entry in entriesToDelete {
      HabitApp.moContext.deleteObject(entry)
    }
    HabitApp.moContext.refreshAllObjects()
    components.minute = 20
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 2
  }
  
  func testMultipleUpdates() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 26
    components.hour = 12
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Monthly, times: 3, createdAt: createdAt)
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    components.minute = 11
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 4
  }
  
}
