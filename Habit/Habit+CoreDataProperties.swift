//
//  Habit+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 7/16/15.
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
    @NSManaged var details: String?
    @NSManaged var frequencyNum: NSNumber?
    @NSManaged var last: NSDate?
    @NSManaged var name: String?
    @NSManaged var notify: NSNumber?
    @NSManaged var parts: String?
    @NSManaged var times: NSNumber?
    @NSManaged var currentStreak: NSNumber?
    @NSManaged var longestStreak: NSNumber?
    @NSManaged var total: NSNumber?
    @NSManaged var entries: NSOrderedSet?

}
