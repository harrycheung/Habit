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
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12)
    habitTimes.createdAt = createdAt
    habitTimes.last = createdAt
    
    expect(habitTimes.countBeforeCreatedAt(NSDate())) == 6
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 0)
    habitParts.partsOfDay = [.Morning, .MidMorning, .MidDay, .Evening]
    habitParts.createdAt = createdAt
    habitParts.last = createdAt
    
    expect(habitParts.countBeforeCreatedAt(NSDate())) == 2
    
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habitYesterday = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12)
    habitYesterday.createdAt = yesterday
    habitYesterday.last = yesterday
    
    expect(habitYesterday.countBeforeCreatedAt(NSDate())) == 0
  }
  
  func testEntriesOnDay() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 3
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    components.day += 1
    for _ in 0...5 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.day += 1
    for _ in 0...5 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.day += 1
    for _ in 0...5 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    expect(habit.totalCount()) == 18
    expect(habit.completedCount()) == 18
    components.day -= 1
    expect(habit.entriesOnDay(calendar.dateFromComponents(components)!).count) == 6
  }
  
  func testTimes() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.useTimes).to(beTrue())
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    components.hour = 1
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(components)!
    components.hour = 3
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(components)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    components.hour = 2
    let since = calendar.dateFromComponents(components)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    components.hour = 12
    let update = calendar.dateFromComponents(components)!
    habit.updateNext(update)
    expect(habit.totalCount()) == 5
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 4
    expect(habit.progress()) == 0.2
    expect(habit.next!) == update
    components.minute = 10
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.next!) == update
  }
  
  func testParts() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Daily, times: 12)
    habit.partsOfDay = [.Morning, .MidDay, .Afternoon]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.useTimes).to(beFalse())
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    components.hour = 8
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(components)!
    components.hour = 12
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(components)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    components.hour = 11
    let since = calendar.dateFromComponents(components)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    components.hour = 20
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 3
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 2
    expect(habit.progress()) == 1 / 3.0
    components.hour = 9
    components.day += 1
    let expectedNext = calendar.dateFromComponents(components)
    expect(habit.next!) == expectedNext
    components.hour = 20
    components.minute = 10
    components.day -= 1
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.next!) == expectedNext
  }
  
  func testTimesYesterday() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 15
    let today = calendar.dateFromComponents(components)!
    components.hour = 11
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12)
    habit.createdAt = yesterday
    habit.last = yesterday
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 13
    expect(habit.skippedCount()) == 13
    components.hour = 14
    components.day += 1
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
  func testPartsYesterday() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 15
    let today = calendar.dateFromComponents(components)!
    components.hour = 14
    components.day -= 1
    let yesterday = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily parts", details: "", frequency: .Daily, times: 0)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.createdAt = yesterday
    habit.last = yesterday
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 3
    expect(habit.skippedCount()) == 3
    components.hour = 0
    components.day += 2
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
  func testTimesTodayPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 8
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Today daily 12 times", details: "", frequency: .Daily, times: 12)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.hour = 12
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.hour = 13
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    components.hour = 12
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.hour = 13
    components.minute = 1
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    components.hour = 14
    components.minute = 0
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testPartsTodayPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.hour = 0
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Today daily parts", details: "", frequency: .Daily, times: 0)
    habit.partsOfDay = [.Morning, .MidDay]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.hour = 11
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    components.hour = 13
    expect(habit.next!) == calendar.dateFromComponents(components)
    
    components.hour = 14
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    components.hour = 13
    expect(habit.next!) == calendar.dateFromComponents(components)
    
    components.hour = 14
    components.minute = 1
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    components.day += 1
    components.hour = 9
    components.minute = 0
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
  func testTimesYesterdayPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 1
    components.hour = 0
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 12)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.day += 1
    components.hour = 12
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 17
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.hour = 13
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 17
    components.hour = 12
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.hour = 13
    components.minute = 1
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 18
    components.hour = 14
    components.minute = 0
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testPartsYesterdayPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
    components.day -= 1
    components.hour = 0
    components.minute = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Yesterday daily 12 times", details: "", frequency: .Daily, times: 0)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.day += 1
    components.hour = 11
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 4
    components.hour = 13
    expect(habit.next!) == calendar.dateFromComponents(components)
    
    components.hour = 14
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 4
    components.hour = 13
    expect(habit.next!) == calendar.dateFromComponents(components)
    
    components.hour = 14
    components.minute = 1
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 5
    components.day += 1
    components.hour = 0
    components.minute = 0
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
  func testTimesTwoDaysAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 0
    let today = calendar.dateFromComponents(components)!
    components.day -= 2
    let twoDaysAgo = calendar.dateFromComponents(components)
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 8)
    habit.createdAt = twoDaysAgo
    habit.last = twoDaysAgo
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 16
    components.day += 2
    components.hour = 3
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
  func testPartsTwoDaysAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.hour = 0
    let today = calendar.dateFromComponents(components)!
    components.day -= 2
    let twoDaysAgo = calendar.dateFromComponents(components)
    let habit = Habit(context: context!, name: "2 days ago daily 8 times", details: "", frequency: .Daily, times: 0)
    habit.partsOfDay = [.Morning, .MidDay, .Evening]
    habit.createdAt = twoDaysAgo
    habit.last = twoDaysAgo
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 6
    components.day += 2
    components.hour = 9
    expect(habit.next!) == calendar.dateFromComponents(components)
  }
  
}
