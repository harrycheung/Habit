//
//  Habit.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class Habit: NSManagedObject {
  static let DAILY = 0;
  static let WEEKLY = 1;
  static let MONTHLY = 2;
  static let ANNUALLY = 3;

  @NSManaged var name: String
  @NSManaged var details: String
  @NSManaged var `repeat`: NSNumber
  @NSManaged var times: NSNumber
  @NSManaged var last: NSDate
  
  class func create(moc moc: NSManagedObjectContext, name: String, details: String, `repeat`: Int, times: Int) -> Habit {
    let habit = NSEntityDescription.insertNewObjectForEntityForName("Habit", inManagedObjectContext: moc) as! Habit
    habit.name = name
    habit.details = details
    habit.`repeat` = `repeat`
    habit.times = times
    return habit
  }
  
  func isNew() -> Bool {
    return committedValuesForKeys(nil).count == 0
  }
  
  //  public TimeSpan DueIn() {
  //  DateTime nextDue = DateTime.Today;
  //  switch (Frequency) {
  //  case Habit.DAILY:
  //  nextDue = LastCompleted.AddHours(24.0 / Repeat);
  //  break;
  //  case Habit.WEEKLY:
  //  nextDue = LastCompleted.AddDays(7.0 / Repeat);
  //  break;
  //  case Habit.MONTHLY:
  //  nextDue = LastCompleted.AddDays(30.0 / Repeat);
  //  break;
  //  case Habit.ANNUALLY:
  //  nextDue = LastCompleted.AddDays(365.0 / Repeat);
  //  break;
  //  }
  //  return nextDue.Subtract(DateTime.Today);
  //  }


}
