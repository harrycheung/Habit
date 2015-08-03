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
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6)
    habitTimes.createdAt = createdAt
    habitTimes.last = createdAt
    
    expect(habitTimes.countBeforeCreatedAt(createdAt)) == 3
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0)
    habitParts.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Saturday]
    habitParts.createdAt = createdAt
    habitParts.last = createdAt
    
    expect(habitParts.countBeforeCreatedAt(createdAt)) == 3
  }
  
  func testEntriesOnWeek() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
    components.day -= 22
    components.hour = 0
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 6)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    for _ in 0...2 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.day += 7
    for _ in 0...2 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.day += 7
    for _ in 0...2 {
      components.hour += 1
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    expect(habit.totalCount()) == 9
    expect(habit.completedCount()) == 9
    components.day -= 7
    expect(habit.entriesOnWeek(calendar.dateFromComponents(components)!).count) == 3
  }
  
  func testTimes() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 1
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 5)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    let entryComponents = calendar.components([.Year, .Month, .Day, .Hour], fromDate: createdAt)
    entryComponents.hour = 12
    entryComponents.day += 1 // Monday
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(entryComponents)!
    entryComponents.day += 3 // Thursday
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(entryComponents)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    entryComponents.day -= 1 // Wednesday
    let since = calendar.dateFromComponents(entryComponents)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    entryComponents.day += 3 // Saturday
    habit.updateNext(calendar.dateFromComponents(entryComponents)!)
    expect(habit.totalCount()) == 4
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 3
    expect(habit.progress()) == 1 / 4.0
    entryComponents.day += 1
    entryComponents.hour = 0
    expect(habit.next!) == calendar.dateFromComponents(entryComponents)!
  }
  
  func testParts() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 1
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Weekly, times: 0)
    habit.daysOfWeek = [.Sunday, .Tuesday, .Wednesday, .Friday, .Saturday]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    let entryComponents = calendar.components([.Year, .Month, .Day, .Hour], fromDate: createdAt)
    entryComponents.hour = 12
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(entryComponents)!
    entryComponents.day += 2 // Tuesday
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(entryComponents)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    entryComponents.day -= 1 // Monday
    let since = calendar.dateFromComponents(entryComponents)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    entryComponents.day += 4 // Friday
    habit.updateNext(calendar.dateFromComponents(entryComponents)!)
    expect(habit.totalCount()) == 3
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 2
    expect(habit.progress()) == 1 / 3.0
    entryComponents.day += 1
    entryComponents.hour = 0
    expect(habit.next!) == calendar.dateFromComponents(entryComponents)!
  }

  func testTimes2WeeksAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday, .Hour], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    components.hour = 0
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 5)
    habit.createdAt = createdAt
    habit.last = createdAt
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 9
    expect(habit.skippedCount()) == 9
    components.weekOfYear += 2
    components.hour -= Int(48 - 1.4 * 24)
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }

  func testParts2WeeksAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 3 // Tuesday
    let today = calendar.dateFromComponents(components)!
    components.weekOfYear -= 2
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "2 weeks ago weekly 5", details: "", frequency: .Weekly, times: 0)
    habit.daysOfWeek = [.Sunday, .Monday, .Wednesday, .Friday, .Saturday]
    habit.createdAt = createdAt
    habit.last = createdAt
    habit.updateNext(today)
    
    expect(habit.totalCount()) == 10
    expect(habit.skippedCount()) == 10
    components.weekOfYear += 2
    components.weekday += 2 // Thursday
    expect(habit.next!) == calendar.dateFromComponents(components)
  }

  func testTimesPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 1 // Sunday
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly 7 times", details: "", frequency: .Weekly, times: 7)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.weekday = 4 // Wednesday
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.weekday = 6 // Friday
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 4
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }

  func testPartsPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Year, .WeekOfYear, .Weekday], fromDate: NSDate())
    components.weekday = 2 // Monday
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "Weekly parts", details: "", frequency: .Weekly, times: 0)
    habit.daysOfWeek = [.Monday, .Tuesday, .Thursday, .Friday]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.weekday = 4 // Thursday
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    components.weekday = 6 // Friday
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 3
    components.weekday = 7 // Saturday
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }

}
