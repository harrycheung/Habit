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
  }
    
  override func tearDown() {
    super.tearDown()
    context = nil
  }
  
  func testCountBeforeCreatedDaily() {
    let calendar = NSCalendar.currentCalendar()
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
  }
  
  func testDateRange() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(start) == calendar.dateFromComponents(components)
    components.hour = 24
    expect(end) == calendar.dateFromComponents(components)
  }
  
  func testEntriesOnDay() {
    let calendar = NSCalendar.currentCalendar()
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
    let calendar = NSCalendar.currentCalendar()
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
  
  func testTimesYesterday() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(today)) == 14
    expect(habit.skippedCount()) == 14
  }
  
  func testPartsYesterday() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(today)) == 3
    expect(habit.skippedCount()) == 3
  }
  
  func testTimesTodayPartial() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(now)) == 2
    expect(habit.skippedCount()) == 2
  }
  
  func testPartsTodayPartial() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(now)) == 1
    expect(habit.skippedCount()) == 1
  }
  
  func testTimesYesterdayPartial() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(now)) == 14
    expect(habit.skippedCount()) == 14
  }
  
  func testPartsYesterdayPartial() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(now)) == 4
    expect(habit.skippedCount()) == 4
  }
  
  func testTimesTwoDaysAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 9
    let today = calendar.dateFromComponents(components)!
    components.day -= 2
    let twoDaysAgo = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: twoDaysAgo)
    habit.update(today)
    
    expect(habit.totalCount(today)) == 16
    expect(habit.totalCount()) == 29
    expect(habit.skipBefore(today)) == 16
    expect(habit.skippedCount()) == 16
  }
  
  func testPartsTwoDaysAgo() {
    let calendar = NSCalendar.currentCalendar()
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
    expect(habit.skipBefore(today)) == 6
    expect(habit.skippedCount()) == 6
  }
  
  func testTimesCompletion() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
    expect(habit.useTimes).to(beTrue())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 17
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      entries[2].skip()
      entries[3].complete()
      components.hour = 23
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
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
    expect(habit.useTimes).to(beFalse())
    components.minute = 10
    habit.update(calendar.dateFromComponents(components)!)
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      let results = try context!.executeFetchRequest(request)
      let entries = (results[0] as! Habit).entries!.array as! [Entry]
      entries[0].complete()
      entries[1].complete()
      components.hour = 14
      var now = calendar.dateFromComponents(components)
      expect(habit.totalCount(now)) == 2
      expect(habit.completedCount()) == 2
      expect(habit.skippedCount()) == 0
      expect(habit.progress(now)) == 1
      entries[2].skip()
      components.hour = 23
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
  
  func testTimesSkipADay() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 2
    components.hour = 9
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
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
    components.day += 2
    components.hour = 11
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 3
    expect(habit.skippedCount()) == 2 + 8 + 3
    expect(habit.totalCount(now)) == 16
    expect(habit.progress(now)) == 3 / 16.0
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
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 2
    components.hour = 12
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0, createdAt: createdAt)
    habit.partsOfDay = [.Morning, .MidMorning, .MidDay, .Afternoon, .Evening]
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
    components.day += 2
    components.hour = 14
    let now = calendar.dateFromComponents(components)!
    habit.update(now)
    habit.skipBefore(now)
    expect(habit.completedCount()) == 2
    expect(habit.skippedCount()) == 1 + 5 + 3
    expect(habit.totalCount(now)) == 11
    expect(habit.progress(now)) == 2 / 11.0
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
  
}
