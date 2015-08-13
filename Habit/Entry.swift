//
//  Entry.swift
//  Habit
//
//  Created by harry on 6/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class Entry: NSManagedObject {
  
  convenience init(context: NSManagedObjectContext, habit: Habit, createdAt: NSDate) {
    let entityDescription = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.createdAt = createdAt
    createdAtTimeZone = NSTimeZone.localTimeZone().name
    skipped = false
  }

}
