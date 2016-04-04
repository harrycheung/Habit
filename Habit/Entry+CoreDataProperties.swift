//
//  Entry+CoreDataProperties.swift
//  Habit
//
//  Created by harry on 8/31/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData

extension Entry {

    @NSManaged var due: NSDate?
    @NSManaged var number: NSNumber?
    @NSManaged var stateRaw: NSNumber?
    @NSManaged var period: String?
    @NSManaged var habit: Habit?

}
