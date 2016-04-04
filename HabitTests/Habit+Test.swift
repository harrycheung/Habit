//
//  Habit+Test.swift
//  Habit
//
//  Created by harry on 9/21/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//


@testable import Habit

extension Habit {
  
  func entryCountBefore(date: NSDate) -> Int {
    return entries!.filteredOrderedSetUsingPredicate(NSPredicate(format: "due <= %@", date)).count
  }
  
}
