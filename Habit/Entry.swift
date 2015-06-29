//
//  Entry.swift
//  Habit
//
//  Created by harry on 6/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

@objc(Entry)
class Entry: NSManagedObject {

  class func create(moc moc: NSManagedObjectContext, habit: Habit) -> Entry {
    let entry = NSEntityDescription.insertNewObjectForEntityForName("Entry", inManagedObjectContext: moc) as! Entry
    entry.habit = habit
    entry.createdAt = NSDate()
    return entry
  }

}
