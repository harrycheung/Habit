//
//  History+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 8/12/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension History {

    @NSManaged var completed: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var frequencyNum: NSNumber?
    @NSManaged var total: NSNumber?
    @NSManaged var habit: Habit?

}
