//
//  HabitManagerTests.swift
//  Habit
//
//  Created by harry on 10/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import XCTest
import CoreData
import Nimble

@testable import Habit

class HabitManagerTests: XCTestCase {
  
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

  func testHabitCreate() {
    HabitApp.startOfDay = 8 * 60  // 8am
    HabitApp.endOfDay = 20 * 60   // 8pm
    
    let createdAt = HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 7, minute: 0)!
    let B = Habit(context: HabitApp.moContext, name: "B", details: "", frequency: .Daily, times: 2, createdAt: createdAt)
    expect(B.update(createdAt).count) == 4
    
    HabitManager.reload(createdAt)
    expect(HabitManager.currentCount) == 2
    expect(HabitManager.upcomingCount) == 2
    expect(HabitManager.current[0].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 14, minute: 0)
    expect(HabitManager.current[1].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 20, minute: 0)
    expect(HabitManager.upcoming[0].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 14, minute: 0)
    expect(HabitManager.upcoming[1].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 20, minute: 0)
    
    let C = Habit(context: HabitApp.moContext, name: "C", details: "", frequency: .Daily, times: 2, createdAt: createdAt)
    expect(C.update(createdAt).count) == 4
    
    HabitManager.reload(createdAt)
    expect(HabitManager.currentCount) == 4
    expect(HabitManager.upcomingCount) == 4
    expect(HabitManager.current[1].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 14, minute: 0)
    expect(HabitManager.current[1].habit!.name!) == "C"
    expect(HabitManager.current[3].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 20, minute: 0)
    expect(HabitManager.current[3].habit!.name!) == "C"
    expect(HabitManager.upcoming[1].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 14, minute: 0)
    expect(HabitManager.upcoming[1].habit!.name!) == "C"
    expect(HabitManager.upcoming[3].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 20, minute: 0)
    expect(HabitManager.upcoming[3].habit!.name!) == "C"
    
    let A = Habit(context: HabitApp.moContext, name: "A", details: "", frequency: .Daily, times: 2, createdAt: createdAt)
    expect(A.update(createdAt).count) == 4
    
    HabitManager.reload(createdAt)
    expect(HabitManager.currentCount) == 6
    expect(HabitManager.upcomingCount) == 6
    expect(HabitManager.current[0].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 14, minute: 0)
    expect(HabitManager.current[0].habit!.name!) == "A"
    expect(HabitManager.current[3].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 20, minute: 0)
    expect(HabitManager.current[3].habit!.name!) == "A"
    expect(HabitManager.upcoming[0].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 14, minute: 0)
    expect(HabitManager.upcoming[0].habit!.name!) == "A"
    expect(HabitManager.upcoming[3].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 20, minute: 0)
    expect(HabitManager.upcoming[3].habit!.name!) == "A"
    
    let now = HabitApp.calendar.date(year: 2015, month: 8, day: 27, hour: 21, minute: 0)!
    HabitManager.deleteEntries(after: now, habit: B, save: true)
    HabitManager.reload(now)
    expect(HabitManager.currentCount) == 6
    expect(HabitManager.upcomingCount) == 4
    HabitManager.createEntries(after: now, currentDate: now, habit: B, save: true)
    HabitManager.reload(now)
    expect(HabitManager.currentCount) == 6
    expect(HabitManager.upcomingCount) == 6
    expect(HabitManager.upcoming[1].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 14, minute: 0)
    expect(HabitManager.upcoming[1].habit!.name!) == "B"
    expect(HabitManager.upcoming[4].due) == HabitApp.calendar.date(year: 2015, month: 8, day: 28, hour: 20, minute: 0)
    expect(HabitManager.upcoming[4].habit!.name!) == "B"
  }
  
}
