//
//  Habit+CoreDataProperties.swift
//  Habit
//
//  Created by Harry on 10/27/17.
//  Copyright © 2017 Harry. All rights reserved.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var completed: Int32
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdAtTimeZone: String?
    @NSManaged public var currentStreak: Int32
    @NSManaged public var details: String?
    @NSManaged public var frequencyRaw: Int32
    @NSManaged public var longestStreak: Int32
    @NSManaged public var name: String?
    @NSManaged public var notify: Bool
    @NSManaged public var parts: String?
    @NSManaged public var paused: Bool
    @NSManaged public var skipped: Int32
    @NSManaged public var times: Int32
    @NSManaged public var histories: NSOrderedSet?

}

// MARK: Generated accessors for histories
extension Habit {

    @objc(insertObject:inHistoriesAtIndex:)
    @NSManaged public func insertIntoHistories(_ value: History, at idx: Int)

    @objc(removeObjectFromHistoriesAtIndex:)
    @NSManaged public func removeFromHistories(at idx: Int)

    @objc(insertHistories:atIndexes:)
    @NSManaged public func insertIntoHistories(_ values: [History], at indexes: NSIndexSet)

    @objc(removeHistoriesAtIndexes:)
    @NSManaged public func removeFromHistories(at indexes: NSIndexSet)

    @objc(replaceObjectInHistoriesAtIndex:withObject:)
    @NSManaged public func replaceHistories(at idx: Int, with value: History)

    @objc(replaceHistoriesAtIndexes:withHistories:)
    @NSManaged public func replaceHistories(at indexes: NSIndexSet, with values: [History])

    @objc(addHistoriesObject:)
    @NSManaged public func addToHistories(_ value: History)

    @objc(removeHistoriesObject:)
    @NSManaged public func removeFromHistories(_ value: History)

    @objc(addHistories:)
    @NSManaged public func addToHistories(_ values: NSOrderedSet)

    @objc(removeHistories:)
    @NSManaged public func removeFromHistories(_ values: NSOrderedSet)

}
