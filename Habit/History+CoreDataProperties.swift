//
//  History+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 9/20/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension History {

    @NSManaged var completed: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var skipped: NSNumber?
    @NSManaged var paused: NSNumber?
    @NSManaged var habit: Habit?

}
