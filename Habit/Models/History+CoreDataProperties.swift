//
//  History+CoreDataProperties.swift
//  Habit
//
//  Created by Harry on 10/27/17.
//  Copyright © 2017 Harry. All rights reserved.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var completed: Int32
    @NSManaged public var date: Date?
    @NSManaged public var total: Int32
    @NSManaged public var habit: Habit?

}
