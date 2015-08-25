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
  }
  
  override func tearDown() {
    super.tearDown()
    context = nil
  }
  
  func testCountBeforeCreatedWeekly() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 5
    let createdAt = calendar.dateFromComponents(components)!
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    
    expect(habitTimes.countBeforeCreatedAt(createdAt)) == 3
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habitParts.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Saturday]
    
    expect(habitParts.countBeforeCreatedAt(createdAt)) == 3
  }
  
  func testDateRange() {
    let calendar = NSCalendar.currentCalendar()
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
  }
  
  func testTimesSkipBefore() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 4
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
    components.weekOfYear += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now)) == 4 + 6 + 2
    expect(habit.skippedCount()) == 12
  }
  
  func testPartsSkipBefore() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 4
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Tuesday, .Thursday, .Friday, .Saturday]
    components.weekOfYear += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now)) == 3 + 5 + 2
    expect(habit.skippedCount()) == 10
  }
  
  func testEntriesOnWeek() {
    let calendar = NSCalendar.currentCalendar()
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
    let calendar = NSCalendar.currentCalendar()
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
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 0
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    habit.update(today)
    
    expect(habit.totalCount(today)) == 4 + 5 + 1
    expect(habit.totalCount()) == 19
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today)) == 10
    expect(habit.skippedCount()) == 10
  }

  func testParts2WeeksAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Sunday, .Monday, .Wednesday, .Friday, .Saturday]
    habit.update(today)
    
    expect(habit.totalCount(today)) == 3 + 5 + 2
    expect(habit.totalCount()) == 18
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today)) == 10
    expect(habit.skippedCount()) == 10
  }
  
  func testTimesCompletion() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 5 times", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)

    let request = NSFetchRequest(entityName: "Habit")
    do {
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.weekday = 5 // Thursday
      components.hour = 18
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      entries[2].skip()
      entries[3].complete()
      components.weekOfYear += 1
      components.weekday = 1
      components.hour = 12
      now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 4
      expect(habit.completedCount()) == 3
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 3 / 4.0
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testPartsCompletion() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 2 // Monday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 3 parts", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.weekday = 6 // Friday
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      entries[2].skip()
      components.weekday = 7 // Saturday
      now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 3
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 2 / 3.0
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testTimesSkipAWeek() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 5 times", details: "", frequency: .Weekly, times: 5, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
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
    habit.skipBefore(now)
    expect(habit.completedCount()) == 3
    expect(habit.skippedCount()) == 1 + 5 + 3
    expect(habit.totalCount(now)) == 4 + 5 + 3
    expect(habit.progress(now)) == 3 / 12.0
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
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 2 // Monday
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 3 parts", details: "", frequency: .Weekly, times: 0, createdAt: createdAt)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
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
    habit.skipBefore(now)
    expect(habit.completedCount()) == 2
    expect(habit.skippedCount()) == 1 + 4 + 3
    expect(habit.totalCount(now)) == 3 + 4 + 3
    expect(habit.progress(now)) == 2 / 10.0
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

}
