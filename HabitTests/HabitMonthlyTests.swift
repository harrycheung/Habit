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
    components.day = 15
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
    entryComponents.day += 5
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
  
}
