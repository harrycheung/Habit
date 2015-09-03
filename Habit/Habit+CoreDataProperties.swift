//
//  Habit+CoreDataProperties.swift
//  Habit
//
//vzxbz  Created by harry on 8/21/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Habit {

    @NSManaged var createdAt: NSDate?
    @NSManaged var createdAtTimeZone: String?
    @NSManaged var currentStreak: NSNumber?
    @NSManaged var details: String?
    @NSManaged var frequencyRaw: NSNumber?
    @NSManaged var longestStreak: NSNumber?
    @NSManaged var name: String?
    @NSManaged var notify: NSNumber?
    @NSManaged var neverAutoSkip: NSNumber?
    @NSManaged var parts: String?
    @NSManaged var times: NSNumber?
    @NSManaged var total: NSNumber?
    @NSManaged var entries: NSOrderedSet?
    @NSManaged var histories: NSOrderedSet?

}
