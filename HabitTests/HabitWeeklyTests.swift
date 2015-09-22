//
//  HabitWeeklyTests.swift
//  Habit
//
//  Created by harry on 8/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import XCTest
import CoreData
import Nimble

@testable import Habit

class HabitWeeklyTests: XCTestCase {

  var context: NSManagedObjectContext?
  
  override func setUp() {
    super.setUp()
    context = HabitApp.setUpInMemoryManagedObjectContext()
    HabitApp.upcoming = true
    HabitApp.startOfDay = 0
    HabitApp.endOfDay = 24 * 60
  }
  
  override func tearDown() {
    super.tearDown()
    context = nil
  }
  
  func testCountBeforeCreatedWeekly() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 17 // Thursday
    components.hour = 12
    let createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    
    expect(habit.countBefore(createdAt)) == 3
    // Sunday
    expect(habit.countBefore(calendar.dateByAddingUnit(.Day, value: 3, toDate: createdAt)!)) == 0
    
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Saturday]
    
    expect(habit.countBefore(createdAt)) == 3
    // Sunday
    expect(habit.countBefore(calendar.dateByAddingUnit(.Day, value: 3, toDate: createdAt)!)) == 1
    expect(habit.firstTodo).to(beNil())
    expect(habit.lastEntry) == createdAt
    
    HabitApp.startOfDay = 8 * 60
    HabitApp.endOfDay = 9 * 60
    // 1 hr/10 min
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    expect(habit.countBefore(createdAt)) == 4
    components.hour = 3
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 3
  }
  
  func testDateRange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 18
    let now = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: now)
    var (start, end) = habit.dateRange(now)
    components.day = 16
    expect(start) == calendar.dateFromComponents(components)
    components.day = 23
    expect(end) == calendar.dateFromComponents(components)
    
    components.day = 30
    (start, end) = habit.dateRange(calendar.dateFromComponents(components)!)
    components.day = 23
    expect(start) == calendar.dateFromComponents(components)
    components.day = 30
    expect(end) == calendar.dateFromComponents(components)
    
    components.year = 2014
    components.month = 12
    components.day = 28
    components.hour = 8
    (start, end) = habit.dateRange(calendar.dateFromComponents(components)!)
    components.hour = 0
    expect(start) == calendar.dateFromComponents(components)
    components.year = 2015
    components.month = 1
    components.day = 4
    expect(end) == calendar.dateFromComponents(components)
    
    components.year = 2015
    components.month = 1
    components.day = 1
    (start, end) = Habit.dateRange(calendar.dateFromComponents(components)!, frequency: .Weekly, includeEnd: false)
    components.year = 2014
    components.month = 12
    components.day = 28
    expect(start) == calendar.dateFromComponents(components)
    components.year = 2015
    components.month = 1
    components.day = 3
    expect(end) == calendar.dateFromComponents(components)
  }
  
  func testOneTimeAWeek() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 18
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 1, createdAt: createdAt)
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    let nextWeek = calendar.dateByAddingUnit(.Day, value: 7, toDate: now)!
    expect(habit.entries!.count) == 2
    expect(habit.entryCountBefore(nextWeek)) == 1
    components.day = 23
    components.hour = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day = 30
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday]
    habit.update(now)
    expect(habit.entries!.count) == 1
    expect(habit.entryCountBefore(nextWeek)) == 1
    components.day = 24
    components.hour = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Saturday]
    habit.update(now)
    expect(habit.entries!.count) == 1
    expect(habit.entryCountBefore(nextWeek)) == 1
  }
  
  func testTimesSkip() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 19
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    let now = calendar.dateByAddingUnit(.WeekOfYear, value: 2, toDate: createdAt)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 4 + 6 + 2
    expect(habit.skipped!.integerValue) == 12
    let todo = NSDateComponents()
    todo.year = 2015
    todo.month = 9
    todo.day = 2
    todo.hour = 12
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(todo)!
    todo.day = 13
    todo.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(todo)!
  }
  
  func testPartsSkip() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 4 // Wednesday
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Tuesday, .Thursday, .Friday, .Saturday]
    components.weekOfYear += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 3 + 5 + 2
    expect(habit.skipped!.integerValue) == 10
    components.weekday = 6
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.weekOfYear += 2
    components.weekday = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testEntriesOnWeek() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 22
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)    
    components.day += 22
    habit.update(calendar.dateFromComponents(components)!)
    components.day -= 7
    expect(habit.entriesOnDate(calendar.dateFromComponents(components)!).count) == 6
  }
  
  func testUpdateHistory() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 22
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    components.day += 22
    habit.update(calendar.dateFromComponents(components)!)
    
    let history = (habit.histories!.array as! [History])[1]
    expect(history.completed) == 0
    expect(history.skipped) == 0
    let entries = habit.entriesOnDate(history.date!)
    entries[0].complete()
    entries[1].complete()
    entries[2].skip()
    expect(history.completed) == 2
    expect(history.skipped) == 1
  }

  func testTimes2WeeksAgo() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 0
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 4 + 5 + 1
    expect(habit.entries!.count) == 4 + 5 + 5 + 5
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 10
    expect(habit.skipped!.integerValue) == 10
    components.weekOfYear += 2
    components.hour = Int(0.8 * 24)
    components.minute = Int((0.8 * 24 * 60) % 60)
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.weekOfYear += 2
    components.weekday = 1
    components.hour = 0
    components.minute = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }

  func testParts2WeeksAgo() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Monday, .Wednesday, .Friday, .Saturday]
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 3 + 5 + 2
    expect(habit.entries!.count) == 3 + 5 + 5 + 5
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 10
    expect(habit.skipped!.integerValue) == 10
    components.weekOfYear += 2
    components.weekday = 5
    components.hour = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.weekOfYear += 2
    components.weekday = 1
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesCompletion() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 5 times", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)

    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.weekday = 5 // Thursday
      components.hour = 18
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 0
      expect(habit.progress(now)) == 1
      components.weekday = 6 // Friday
      components.hour = Int(0.6 * 24)
      components.minute = Int((0.6 * Double(HabitApp.dayMinutes)) % 60)
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.weekOfYear += 2
      components.weekday = 1
      components.hour = 0
      components.minute = 0
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
      entries[2].skip()
      entries[3].complete()
      components.weekOfYear -= 1
      components.weekday = 1
      components.hour = 12
      now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 4
      expect(habit.entries!.count) == 4 + 5
      expect(habit.completed!.integerValue) == 3
      expect(habit.skipped!.integerValue) == 1
      expect(habit.progress(now)) == 3 / 4.0
      components.weekday = 2
      components.hour = Int(0.4 * 24)
      components.minute = Int((0.4 * Double(HabitApp.dayMinutes)) % 60)
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.weekOfYear += 1
      components.weekday = 1
      components.hour = 0
      components.minute = 0
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testPartsCompletion() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 2 // Monday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 3 parts", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      components.weekday = 6 // Friday
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 1
      expect(habit.skipped!.integerValue) == 0
      expect(habit.progress(now)) == 1 / 2.0
      components.hour = 0
      components.minute = 0
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.weekOfYear += 1
      components.weekday = 7
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
      entries[1].skip()
      components.weekOfYear -= 1
      components.weekday = 7 // Saturday
      now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 3
      expect(habit.completed!.integerValue) == 1
      expect(habit.skipped!.integerValue) == 1
      expect(habit.progress(now)) == 1 / 3.0
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      components.weekOfYear += 1
      expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testTimesSkipAWeek() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 5 times", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
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
    components.weekOfYear += 2
    components.weekday = 5 // Thursday
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 3
    expect(habit.skipped!.integerValue) == 1 + 5 + 3
    expect(habit.entryCountBefore(now)) == 4 + 5 + 3
    expect(habit.progress(now)) == 3 / 12.0
    components.weekday = 6 // Friday
    components.hour = Int(0.6 * 24)
    components.minute = Int((0.6 * Double(HabitApp.dayMinutes)) % 60)
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.weekOfYear += 2
    components.weekday = 1
    components.hour = 0
    components.minute = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 4
    expect(histories[0].completed) == 3
    expect(histories[0].skipped) == 1
    expect(histories[1].completed) == 0
    expect(histories[1].skipped) == 5
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 3
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 0
  }
  
  func testPartsSkipAWeek() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 2 // Monday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 3 parts", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      entries[2].skip()
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
    components.weekOfYear += 2
    components.weekday = 6 // Friday
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 2
    expect(habit.skipped!.integerValue) == 1 + 4 + 3
    expect(habit.entryCountBefore(now)) == 3 + 4 + 3
    expect(habit.progress(now)) == 2 / 10.0
    components.weekday = 7
    components.hour = 0
    components.minute = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.weekOfYear += 1
    components.weekday = 7
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 4
    expect(histories[0].completed) == 2
    expect(histories[0].skipped) == 1
    expect(histories[1].completed) == 0
    expect(histories[1].skipped) == 4
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 3
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 0
  }
  
  func testDaylightSpringForward() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 6
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    components.day = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    let entries = habit.entriesOnDate(now)
    expect(entries.count) == 6
    components.day = 6
    components.hour = 20
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day = 22
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testDaylightFallBackward() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 10
    components.day = 25
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    components.month = 11
    components.day = 1
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    let entries = habit.entriesOnDate(now)
    expect(entries.count) == 6
    components.month = 10
    components.day = 26
    components.hour = 4
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.month = 11
    components.day = 15
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 15 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 23 // Sunday
    components.hour = 12
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 4, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 8
    components.month = 8
    components.day = 24 // Monday
    components.hour = 7 + 6
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
    components.month = 9
    components.day = 5
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    
    components.month = 8
    components.day = 26 // Wednesday
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 4, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 6
    components.day = 28
    components.hour = 7 + 2
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
    
    components.month = 8
    components.day = 29 // Saturday
    components.hour = 23
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 4, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 4
    components.day = 31
    components.hour = 7 + 6
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
  }
  
  func testPartsCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 15 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 23 // Sunday
    components.hour = 12
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday, .Saturday]
    habit.update(createdAt)
    expect(habit.entries!.count) == 10
    components.month = 8
    components.day = 24 // Monday
    components.hour = 15
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
    components.month = 9
    components.day = 5 // Saturday
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
    
    components.month = 8
    components.day = 26
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday, .Saturday]
    habit.update(createdAt)
    expect(habit.entries!.count) == 8
    components.month = 8
    components.day = 27
    components.hour = 15
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
    
    components.month = 8
    components.day = 29
    components.hour = 19
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday, .Saturday]
    habit.update(createdAt)
    expect(habit.entries!.count) == 5
    components.month = 8
    components.day = 31
    components.hour = 15
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
  }
  
  func testPartsAllWeekCustomEnd() {
    HabitApp.endOfDay = 22 * 60
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 7 // Monday
    components.hour = 16
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    components.day = 8 // Tuesday
    components.hour = 22
    components.minute = 0
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)!
  }
  
  func testPartsAddUpcoming() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 7 // Monday
    components.hour = 12
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Monday, .Tuesday, .Wednesday]
    components.minute = 10
    HabitApp.upcoming = false
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 2
    HabitApp.upcoming = true
    components.minute = 15
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 6
  }
  
  func testFrequencyChange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 9
    components.day = 15 // Tuesday
    components.hour = 12
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Friday]
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 6
    
    (habit.entries!.objectAtIndex(0) as! Entry).complete()
    habit.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Thursday, .Friday]
    var predicate = NSPredicate(format: "due > %@", NSDate())
    var entriesToDelete = habit.entries!.filteredOrderedSetUsingPredicate(predicate).array as! [Entry]
    for entry in entriesToDelete {
      context!.deleteObject(entry)
    }
    context!.refreshAllObjects()
    components.minute = 20
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 7
    
    components.day = 5 // Saturday
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: context!, name: "Habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Friday, .Saturday]
    components.day = 19
    let today = calendar.dateFromComponents(components)!
    habit.update(today)
    expect(habit.entries!.count) == 15
    
    habit.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday]
    predicate = NSPredicate(format: "due > %@", today)
    entriesToDelete = habit.entries!.filteredOrderedSetUsingPredicate(predicate).array as! [Entry]
    for entry in entriesToDelete {
      context!.deleteObject(entry)
    }
    context!.refreshAllObjects()
    habit.update(today)
    expect(habit.entries!.count) == 16
  }

}
