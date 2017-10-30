//
//  NSManagedObject+Custom.swift
//  Habit
//
//  Created by harry on 9/20/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import CoreData

extension NSManagedObject {
  
  var isNew: Bool {
    return objectID.isTemporaryID
  }
  
}
