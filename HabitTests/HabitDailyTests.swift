//
//  HabitDailyTests.swift
//  HabitTests
//
//  Created by harry on 6/26/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import XCTest
import CoreData
import Nimble

@testable import Habit

class HabitDailyTests: XCTestCase {
  
  var context: NSManagedObjectContext?
    
  override func setUp() {
    super.setUp()
    context = HabitApp.setUpInMemoryManagedObjectContext()
    HabitApp.upcoming = true
  }
    
  override func tearDown() {
    super.tearDown()
    context = nil
  }
  
  func testCountBeforeCreatedDaily() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 13
    let createdAt = calendar.dateFromComponents(components)!
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    expect(habitTimes.countBeforeCreatedAt(createdAt)) == 6
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habitParts.partsOfDay = [.Morning, .MidMorning, .MidDay, .Evening]
    
    expect(habitParts.countBeforeCreatedAt(createdAt)) == 3
    
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habitYesterday = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: yesterday)
    
    expect(habitYesterday.countBeforeCreatedAt(createdAt)) == 0
    expect(habitYesterday.firstTodo).to(beNil())
  }
  
  func testDateRange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 10
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 5, createdAt: now)
    var (start, end) = habit.dateRange(now)
    components.hour = 0
    expect(start) == calendar.dateFromComponents(components)
    components.hour = 24
    expect(end) == calendar.dateFromComponents(components)
    components.day = 1
    components.hour = 0
    (start, end) = habit.dateRange(calendar.dateFromComponents(components)!)
    components.month = 7
    components.day = 31
    components.hour = 0
    expect(start) == calendar.dateFromComponents(components)!
    components.hour = 24
    expect(end) == calendar.dateFromComponents(components)!
  }
  
  func testTimesSkipBefore() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 6, createdAt: createdAt)
    components.day += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now).count) == 4 + 6 + 2
    expect(habit.skippedCount()) == 12
    components.hour = 12
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsSkipBefore() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon, .Evening]
    components.day += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skipBefore(now).count) == 4 + 4 + 0
    expect(habit.skippedCount()) == 8
    components.hour = 9
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testEntriesOnDay() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 3
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    components.day += 3
    habit.update(calendar.dateFromComponents(components)!)    
    components.day -= 2
    expect(habit.entriesOnDate(calendar.dateFromComponents(components)!).count) == 12
  }
  
  func testUpdateHistory() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 3
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    components.day += 3
    habit.update(calendar.dateFromComponents(components)!)
    
    let history = (habit.histories!.array as! [History])[1]
    expect(history.completed) == 0
    expect(history.skipped) == 0
    let entries = habit.entriesOnDate(history.date!)
    entries[0].complete()
    entries[1].complete()
    entries[2].skip()
    entries[3].complete()
    entries[4].skip()
    expect(history.completed) == 3
    expect(history.skipped) == 2
  }
  
  func testOneTimeADay() {
    let calendar = HabitApp.calendar
    let createdAt = calendar.dateBySettingHour(8, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
    let now = calendar.dateBySettingHour(10, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
    habit.update(now)
    let tomorrow = calendar.dateByAddingUnit(.Day, value: 1, toDate: now)!
    expect(habit.totalCount()) == 2
    expect(habit.totalCount(tomorrow)) == 1
    let first = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: tomorrow, options: NSCalendarOptions(rawValue: 0))!
    expect(habit.firstTodo!.due!) == first
    expect(habit.lastEntry) == calendar.dateByAddingUnit(.Day, value: 1, toDate: first)
  }
  
  func testTimesYesterday() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 15
    let today = calendar.dateFromComponents(components)!
    components.hour = 11
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: yesterday)
    habit.update(today)
    
    expect(habit.totalCount(today)) == 14
    expect(habit.totalCount()) == 31
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today).count) == 14
    expect(habit.skippedCount()) == 14
    components.day += 1 // today
    components.hour = 16
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2 // day after tomorrow
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsYesterday() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 15
    let today = calendar.dateFromComponents(components)!
    components.hour = 14
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily parts", details: "", frequency: .Daily, times: 0, createdAt: yesterday)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.update(today)
    
    expect(habit.totalCount(today)) == 3
    expect(habit.totalCount()) == 7
    expect(habit.skippedCount()) == 0
    expect(habit.skipBefore(today).count) == 3
    expect(habit.skippedCount()) == 3
    components.day += 2
    components.hour = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 1
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesTodayPartial() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 8
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Today daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.totalCount(now)) == 2
    expect(habit.totalCount()) == 20
    expect(habit.skipBefore(now).count) == 2
    expect(habit.skippedCount()) == 2
    components.hour = 14
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsTodayPartial() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Today daily parts", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon]
    
    components.hour = 14
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.totalCount(now)) == 1
    expect(habit.totalCount()) == 5
    expect(habit.skipBefore(now).count) == 1
    expect(habit.skippedCount()) == 1
    components.hour = 15
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 1
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesYesterdayPartial() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 1
    components.hour = 8
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    components.day += 1
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.totalCount(now)) == 14
    expect(habit.totalCount()) == 32
    expect(habit.skipBefore(now).count) == 14
    expect(habit.skippedCount()) == 14
    components.hour = 14
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsYesterdayPartial() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 1
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon]
    
    components.day += 1
    components.hour = 14
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.totalCount(now)) == 4
    expect(habit.totalCount()) == 8
    expect(habit.skipBefore(now).count) == 4
    expect(habit.skippedCount()) == 4
    components.hour = 15
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 1
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesTwoDaysAgo() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 9
    let today = calendar.dateFromComponents(components)!
    components.day -= 2
    let twoDaysAgo = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: twoDaysAgo)
    habit.update(today)
    
    expect(habit.totalCount(today)) == 16
    expect(habit.totalCount()) == 29
    expect(habit.skipBefore(today).count) == 16
    expect(habit.skippedCount()) == 16
    components.day += 2
    components.hour = 12
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsTwoDaysAgo() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 9
    let today = calendar.dateFromComponents(components)!
    components.day -= 2
    let twoDaysAgo = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: twoDaysAgo)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.update(today)
    
    expect(habit.totalCount(today)) == 6
    expect(habit.totalCount()) == 11
    expect(habit.skipBefore(today).count) == 6
    expect(habit.skippedCount()) == 6
    components.day += 2
    components.hour = 13
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesCompletion() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 17
      components.minute = 0
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      components.hour = 18
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      entries[2].skip()
      entries[3].complete()
      components.hour = 23
      now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 4
      expect(habit.completedCount()) == 3
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 3 / 4.0
      components.hour = 24
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testPartsCompletion() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 14
      components.minute = 0
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      components.hour = 15
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      entries[2].skip()
      components.hour = 23
      now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 3
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 1
      expect(habit.progress(now)) == 2 / 3.0
      components.hour = 24
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
  }
  
  func testTimesSkipADay() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 2
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
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
    components.day += 2
    components.hour = 11
    components.minute = 0
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 3
    expect(habit.skippedCount()) == 2 + 8 + 3
    expect(habit.totalCount(now)) == 16
    expect(habit.progress(now)) == 3 / 16.0
    components.hour = 12
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 4
    expect(histories[0].completed) == 3
    expect(histories[0].skipped) == 2
    expect(histories[1].completed) == 0
    expect(histories[1].skipped) == 8
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 3
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 0
  }
  
  func testPartsSkipADay() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 2
    components.hour = 12
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
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
    components.day += 2
    components.hour = 14
    components.minute = 0
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 2
    expect(habit.skippedCount()) == 1 + 5 + 3
    expect(habit.totalCount(now)) == 11
    expect(habit.progress(now)) == 2 / 11.0
    components.hour = 15
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    let histories = habit.histories!.array as! [History]
    expect(histories.count) == 4
    expect(histories[0].completed) == 2
    expect(histories[0].skipped) == 1
    expect(histories[1].completed) == 0
    expect(histories[1].skipped) == 5
    expect(histories[2].completed) == 0
    expect(histories[2].skipped) == 3
    expect(histories[3].completed) == 0
    expect(histories[3].skipped) == 0
  }
  
  func testTimesSkipInMiddle() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 7
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    habit.update(createdAt)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[3].skip()
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
    components.hour = 9
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
  }
  
  func testPartsSkipInMiddle() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 7
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    habit.update(createdAt)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[2].skip()
    } catch let error as NSError {
      NSLog("error: \(error)")
      fail()
    }
    components.hour = 9
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
  }
  
  func testUpcoming() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 23
    components.minute = 55
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
    
    HabitApp.upcoming = false
    habit.update(createdAt)
    expect(habit.totalCount()) == 1
    components.hour = 24
    components.minute = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    
    HabitApp.upcoming = true
    habit.update(createdAt)
    expect(habit.totalCount()) == 2
  }
  
}
