//
//  Entry+CoreDataProperties.swift
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

extension Entry {

    @NSManaged var createdAt: NSDate?
    @NSManaged var createdAtTimeZone: String?
    @NSManaged var skipped: NSNumber?
    @NSManaged var expired: NSNumber?
    @NSManaged var habit: Habit?

}
