//
//  History+CoreDataClass.swift
//  Habit
//
//  Created by Harry on 10/4/17.
//  Copyright © 2017 Harry. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

public class History: NSManagedObject {
  
  var paused: Bool {
    return total == 0
  }
  
  var frequency: Habit.Frequency {
    return habit!.frequency
  }
  
  var percentage: CGFloat {
    if total == 0 {
      return 0
    }
    return CGFloat(completed) / CGFloat(total)
  }
  
  var skipped: Int {
    return 0
  }
  
  convenience init(context: NSManagedObjectContext, habit: Habit, date: Date) {
    let entityDescription = NSEntityDescription.entity(forEntityName: "History", in: context)!
    self.init(entity: entityDescription, insertInto: context)
    self.habit = habit
    self.date = date
  }
  
}
