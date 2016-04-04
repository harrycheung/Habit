//
//  Habit+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 9/21/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData

extension Habit {

    @NSManaged var createdAt: NSDate?
    @NSManaged var createdAtTimeZone: String?
    @NSManaged var currentStreak: NSNumber?
    @NSManaged var details: String?
    @NSManaged var frequencyRaw: NSNumber?
    @NSManaged var longestStreak: NSNumber?
    @NSManaged var name: String?
    @NSManaged var neverAutoSkip: NSNumber?
    @NSManaged var notify: NSNumber?
    @NSManaged var parts: String?
    @NSManaged var paused: NSNumber?
    @NSManaged var times: NSNumber?
    @NSManaged var completed: NSNumber?
    @NSManaged var skipped: NSNumber?
    @NSManaged var entries: NSOrderedSet?
    @NSManaged var histories: NSOrderedSet?

}
