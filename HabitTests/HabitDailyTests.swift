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
  
  func testCountBeforeCreatedDaily() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 10
    components.hour = 13
    let createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    expect(habit.countBefore(createdAt)) == 6
    components.hour = 1
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 0
    components.day = 11
    components.hour = 0
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 12
    
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Evening]
    
    expect(habit.countBefore(createdAt)) == 3
    components.hour = 1
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 0
    components.hour = 16
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 3
    
    components.hour = 13
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: yesterday)
    
    expect(habit.countBefore(createdAt)) == 6
    expect(habit.firstTodo).to(beNil())
    
    HabitApp.startOfDay = 8 * 60
    HabitApp.endOfDay = 9 * 60
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 6, createdAt: NSDate())
    components.hour = 7
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 0
    components.hour = 8
    components.minute = 31
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 3
    components.hour = 9
    expect(habit.countBefore(calendar.dateFromComponents(components)!)) == 6
  }
  
  func testDateRange() {
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 10
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 5, createdAt: now)
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
  
  func testTimesSkip() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 6, createdAt: createdAt)
    components.day += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 4 + 6 + 2
    expect(habit.skipped!.integerValue) == 12
    components.hour = 12
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day += 2
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testPartsSkip() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 8
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon, .Evening]
    components.day += 2
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.skip(before: now).count) == 4 + 4 + 0
    expect(habit.skipped!.integerValue) == 8
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
    let now = calendar.dateBySettingHour(10, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
    habit.update(now)
    let tomorrow = calendar.dateByAddingUnit(.Day, value: 1, toDate: now)!
    expect(habit.entries!.count) == 2
    expect(habit.entryCountBefore(tomorrow)) == 1
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
    let habit = Habit(context: HabitApp.moContext, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: yesterday)
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 14
    expect(habit.entries!.count) == 31
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 14
    expect(habit.skipped!.integerValue) == 14
    components.day++ // today
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
    let habit = Habit(context: HabitApp.moContext, name: "Yesterday daily parts", details: "", frequency: .Daily, times: 0, createdAt: yesterday)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 3
    expect(habit.entries!.count) == 7
    expect(habit.skipped!.integerValue) == 0
    expect(habit.skip(before: today).count) == 3
    expect(habit.skipped!.integerValue) == 3
    components.day += 2
    components.hour = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day++
    components.hour = 0
    expect(habit.lastEntry) == calendar.dateFromComponents(components)!
  }
  
  func testTimesTodayPartial() {
    let calendar = HabitApp.calendar
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 8
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "Today daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.entryCountBefore(now)) == 2
    expect(habit.entries!.count) == 20
    expect(habit.skip(before: now).count) == 2
    expect(habit.skipped!.integerValue) == 2
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
    let habit = Habit(context: HabitApp.moContext, name: "Today daily parts", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon]
    
    components.hour = 14
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.entryCountBefore(now)) == 1
    expect(habit.entries!.count) == 5
    expect(habit.skip(before: now).count) == 1
    expect(habit.skipped!.integerValue) == 1
    components.hour = 15
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day++
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
    let habit = Habit(context: HabitApp.moContext, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    
    components.day++
    components.hour = 12
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.entryCountBefore(now)) == 14
    expect(habit.entries!.count) == 32
    expect(habit.skip(before: now).count) == 14
    expect(habit.skipped!.integerValue) == 14
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
    let habit = Habit(context: HabitApp.moContext, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon]
    
    components.day++
    components.hour = 14
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    expect(habit.entryCountBefore(now)) == 4
    expect(habit.entries!.count) == 8
    expect(habit.skip(before: now).count) == 4
    expect(habit.skipped!.integerValue) == 4
    components.hour = 15
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    components.day++
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: twoDaysAgo)
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 16
    expect(habit.entries!.count) == 29
    expect(habit.skip(before: today).count) == 16
    expect(habit.skipped!.integerValue) == 16
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: twoDaysAgo)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.update(today)
    
    expect(habit.entryCountBefore(today)) == 6
    expect(habit.entries!.count) == 11
    expect(habit.skip(before: today).count) == 6
    expect(habit.skipped!.integerValue) == 6
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 17
      components.minute = 0
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 0
      expect(habit.progress(now)) == 1
      components.hour = 18
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      entries[2].skip()
      entries[3].complete()
      components.hour = 23
      now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 4
      expect(habit.completed!.integerValue) == 3
      expect(habit.skipped!.integerValue) == 1
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 14
      components.minute = 0
      var now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 2
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 0
      expect(habit.progress(now)) == 1
      components.hour = 15
      expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
      entries[2].skip()
      components.hour = 23
      now = calendar.dateFromComponents(components)!
      expect(habit.entryCountBefore(now)) == 3
      expect(habit.completed!.integerValue) == 2
      expect(habit.skipped!.integerValue) == 1
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    components.minute = 10
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
    components.day += 2
    components.hour = 11
    components.minute = 0
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 3
    expect(habit.skipped!.integerValue) == 2 + 8 + 3
    expect(habit.entryCountBefore(now)) == 16
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
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
    habit.skip(before: now)
    expect(habit.completed!.integerValue) == 2
    expect(habit.skipped!.integerValue) == 1 + 5 + 3
    expect(habit.entryCountBefore(now)) == 11
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    habit.update(createdAt)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
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
    let habit = Habit(context: HabitApp.moContext, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    habit.update(createdAt)
    
    do {
      let request = NSFetchRequest(entityName: "Habit")
      let results = try HabitApp.moContext.executeFetchRequest(request)
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
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
    
    HabitApp.upcoming = false
    habit.update(createdAt)
    expect(habit.entries!.count) == 2
    components.hour = 24
    components.minute = 0
    expect(habit.firstTodo!.due!) == calendar.dateFromComponents(components)!
    
    HabitApp.upcoming = true
    habit.update(createdAt)
    expect(habit.entries!.count) == 2
  }
  
  func testTimesCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 15 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 6
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 16
    components.hour = 8
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    components.day = 28
    components.hour = 15
    expect(habit.lastEntry) == calendar.dateFromComponents(components)
    
    components.day = 27
    components.hour = 12
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    habit.update(createdAt)
    expect(habit.entries!.count) == 11
    components.hour = 13
    components.minute = 30
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    
    components.hour = 22
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    habit.update(createdAt)
    components.day = 28
    components.hour = 8
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    expect(habit.entries!.count) == 8
  }
  
  func testPartsCustomStartEnd() {
    HabitApp.startOfDay = 7 * 60 + 30
    HabitApp.endOfDay = 19 * 60 + 30
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 6
    var createdAt = calendar.dateFromComponents(components)!
    var habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon, .Evening]
    habit.update(createdAt)
    expect(habit.entries!.count) == 8
    components.hour = 9
    components.minute = 0
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    components.day = 28
    components.hour = 19
    components.minute = 30
    expect(habit.lastEntry) == calendar.dateFromComponents(components)
    
    components.day = 27
    components.hour = 13
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon, .Evening]
    habit.update(createdAt)
    expect(habit.entries!.count) == 6
    
    components.hour = 22
    createdAt = calendar.dateFromComponents(components)!
    habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon, .Evening]
    habit.update(createdAt)
    components.day = 28
    components.hour = 9
    components.minute = 0
    expect(habit.firstTodo!.due) == calendar.dateFromComponents(components)
    expect(habit.entries!.count) == 4
  }
  
  func testPause() {
    HabitApp.startOfDay = 8 * 60
    HabitApp.endOfDay = 20 * 60
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 8
    components.day = 27
    components.hour = 6
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 24
    components.hour = 12
    habit.skip(before: calendar.dateFromComponents(components)!)
    HabitManager.reload()
    expect(HabitManager.deleteEntries(after: calendar.dateFromComponents(components)!, habit: habit).count) == 8 + 12
    HabitApp.moContext.refreshAllObjects()
    expect(habit.firstTodo).to(beNil())
    expect(habit.entries!.count) == 4
    components.hour = 18
    HabitManager.createEntries(after: calendar.dateFromComponents(components)!,
      currentDate: calendar.dateFromComponents(components)!, habit: habit)
    expect(habit.entries!.count) == 4 + 2 + 12
    
    HabitManager.deleteEntries(after: calendar.dateFromComponents(components)!, habit: habit)
    HabitApp.moContext.refreshAllObjects()
    habit.pausedBool = true
    components.day = 31
    habit.update(calendar.dateFromComponents(components)!)
    habit.pausedBool = false
    HabitManager.createEntries(after: calendar.dateFromComponents(components)!,
      currentDate: calendar.dateFromComponents(components)!, habit: habit)
    expect(habit.entries!.count) == 18
    let histories = habit.histories!.array as! [History]
    expect(calendar.components([.Day], fromDate: histories[0].date!).day) == 27
    expect(calendar.components([.Day], fromDate: histories[1].date!).day) == 28
    expect(histories[1].paused).to(beTrue())
    expect(calendar.components([.Day], fromDate: histories[2].date!).day) == 29
    expect(histories[2].paused).to(beTrue())
    expect(calendar.components([.Day], fromDate: histories[3].date!).day) == 30
    expect(histories[3].paused).to(beTrue())
    expect(calendar.components([.Day], fromDate: histories[4].date!).day) == 31
    expect(calendar.components([.Day], fromDate: histories[5].date!).day) == 1
  }
  
  func testPeriodEndOfMonth() {
    HabitApp.startOfDay = 8 * 60
    HabitApp.endOfDay = 20 * 60
    
    let calendar = HabitApp.calendar
    let components = NSDateComponents()
    components.year = 2015
    components.month = 10
    components.day = 30
    components.hour = 6
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: HabitApp.moContext, name: "A habit", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    components.day = 31
    habit.update(calendar.dateFromComponents(components)!)
    components.month = 11
    components.day = 1
    habit.update(calendar.dateFromComponents(components)!)
    expect(habit.entries!.count) == 4
    let entries = habit.entries!.array as! [Entry]
    expect(entries[0].period) == "Daily30"
    expect(entries[1].period) == "Daily31"
    expect(entries[2].period) == "Daily1"
    expect(entries[3].period) == "Daily2"
  }
  
}
