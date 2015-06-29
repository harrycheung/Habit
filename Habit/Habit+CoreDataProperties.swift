//
//  Habit+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 6/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Habit {

    @NSManaged var details: String?
    @NSManaged var last: NSDate?
    @NSManaged var name: String?
    @NSManaged var frequency: NSNumber?
    @NSManaged var times: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var entries: NSOrderedSet?

}
