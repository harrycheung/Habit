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

  var frequency: Habit.Frequency {
    get {
      return Habit.Frequency(rawValue: frequencyNum!.integerValue)!
    }
    set {
      frequencyNum = newValue.rawValue
    }
  }
  
  var percentage: CGFloat {
    let denom = CGFloat(total!)
    if denom == 0 {
      return 0
    }
    return CGFloat(completed!) / denom
  }
  
  convenience init(context: NSManagedObjectContext, habit: Habit, frequency: Habit.Frequency, date: NSDate) {
    let entityDescription = NSEntityDescription.entityForName("History", inManagedObjectContext: context)!
    self.init(entity: entityDescription, insertIntoManagedObjectContext: context)
    self.habit = habit
    self.frequency = frequency
    self.date = date
  }

}
