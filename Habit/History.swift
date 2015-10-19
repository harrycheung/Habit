//
//  History.swift
//  Habit
//
//  Created by harry on 8/12/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData

class History: NSManagedObject {
  
  var paused: Bool {
    return total!.integerValue == 0
  }

  var frequency: Habit.Frequency {
    return habit!.frequency
  }
  
  var percentage: CGFloat {
    if total!.integerValue == 0 {
      return 0
    }
    return CGFloat(completed!) / CGFloat(total!)
  }
  
  convenience init(context: NSManagedObjectContext, habit: Habit, date: NSDate) {
    let entityDescription = NSEntityDescription.entityForName("History", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.date = date
  }

}
