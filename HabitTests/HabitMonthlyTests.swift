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
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habitTimes = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 5)
    habitTimes.createdAt = createdAt
    habitTimes.last = createdAt
    
    expect(habitTimes.countBeforeCreatedAt(createdAt)) == 2
    
    let habitParts = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0)
    habitParts.partsOfMonth = [.Beginning, .End]
    habitParts.createdAt = createdAt
    habitParts.last = createdAt
    
    expect(habitParts.countBeforeCreatedAt(createdAt)) == 1
  }
  
  func testEntriesOnMonth() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    for _ in 0...2 {
      components.day += 3
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.month += 1
    components.day = 5
    for _ in 0...2 {
      components.day += 5
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    components.month += 1
    components.day = 10
    for _ in 0...2 {
      components.day += 2
      let entry = Entry(context: context!, habit: habit)
      entry.createdAt = calendar.dateFromComponents(components)
    }
    
    expect(habit.totalCount()) == 9
    expect(habit.completedCount()) == 9
    components.month -= 1
    expect(habit.entriesOnMonth(calendar.dateFromComponents(components)!).count) == 3
  }
  
  func testTimes() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 3
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    components.day = 11
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(components)!
    components.day = 17
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(components)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    components.day = 15
    let since = calendar.dateFromComponents(components)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    components.day = 29
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 3
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 2
    expect(habit.progress()) == 1 / 3.0
    components.day = 1
    components.month += 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testParts() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 3
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0)
    habit.partsOfMonth = [.Beginning, .Middle, .End]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    expect(habit.totalCount()) == 0
    expect(habit.completedCount()) == 0
    expect(habit.skippedCount()) == 0
    expect(habit.progress()) == 0
    
    components.day = 11
    let entryA = Entry(context: context!, habit: habit)
    entryA.createdAt = calendar.dateFromComponents(components)!
    components.day = 17
    let entryB = Entry(context: context!, habit: habit)
    entryB.createdAt = calendar.dateFromComponents(components)!
    entryB.skipped = NSNumber(bool: true)
    
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 0.5
    
    components.day = 15
    let since = calendar.dateFromComponents(components)!
    expect(habit.totalCount(since)) == 1
    expect(habit.completedCount(since)) == 0
    expect(habit.skippedCount(since)) == 1
    expect(habit.progress(since)) == 0
    
    components.day = 29
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    expect(habit.completedCount()) == 1
    expect(habit.skippedCount()) == 1
    expect(habit.progress()) == 1 / 2.0
    components.day = 1
    components.month += 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testTimes2MonthsAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4)
    habit.createdAt = createdAt
    habit.last = createdAt
    components.month = 5
    components.day = 5
    habit.updateNext(calendar.dateFromComponents(components)!)
    
    expect(habit.totalCount()) == 6
    expect(habit.skippedCount()) == 6
    components.day = (31 / 4) + 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testParts2MonthsAgo() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 15
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0)
    habit.partsOfMonth = [.Beginning, .End]
    habit.createdAt = createdAt
    habit.last = createdAt
    components.month = 5
    components.day = 5
    habit.updateNext(calendar.dateFromComponents(components)!)
    
    expect(habit.totalCount()) == 3
    expect(habit.skippedCount()) == 3
    components.day = (31 / 3) + 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testTimesPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 10
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 4)
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.day = 20
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    components.day = (3 * 31 / 4) + 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.day = 30
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    components.day = 1
    components.month += 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
  func testPartsPartial() {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 2015
    components.month = 3
    components.day = 10
    let createdAt = calendar.dateFromComponents(components)!
    let habit = Habit(context: context!, name: "A habit", details: "", frequency: .Monthly, times: 0)
    habit.partsOfMonth = [.Beginning, .End]
    habit.createdAt = createdAt
    habit.last = createdAt
    
    components.day = 12
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 1
    components.day = 1
    components.month += 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
    
    components.day = 5
    habit.updateNext(calendar.dateFromComponents(components)!)
    expect(habit.totalCount()) == 2
    components.day = 31 / 3 + 1
    expect(habit.next!) == calendar.dateFromComponents(components)!
  }
  
}
