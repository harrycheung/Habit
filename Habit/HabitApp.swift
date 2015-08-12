//
//  HabitApp.swift
//  Habit
//
//  Created by harry on 7/23/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HabitApp {
  
  // User setting strings
  static let timeZoneSettingKey = "timezone"
  static let notificationSettingKey = "notification"
  static let colorSettingKey = "color"
  static let upcomingSettingKey = "upcoming"
  
  // App colors
  static let green = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
  static let yellow = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
  
  // User color options
  static let blueTint = UIColor(red: 42.0 / 255.0, green: 132.0 / 255.0, blue: 219.0 / 255.0, alpha: 1)
  static let purpleTint = UIColor(red: 155.0 / 255.0, green: 79.0 / 255.0, blue: 172.0 / 255.0, alpha: 1)
  static let greenTint = UIColor(red: 46.0 / 255.0, green: 180.0 / 255.0, blue: 113.0 / 255.0, alpha: 1)
  static let darkBlueTint = UIColor(red: 52.0 / 255.0, green: 73.0 / 255.0, blue: 120.0 / 255.0, alpha: 1)
  static let greyTint = UIColor(red: 130.0 / 255.0, green: 130.0 / 255.0, blue: 130.0 / 255.0, alpha: 1)
  static let orangeTint = UIColor(red: 230.0 / 255.0, green: 146.0 / 255.0, blue: 45.0 / 255.0, alpha: 1)
  static let colors = [blueTint, purpleTint, greenTint, darkBlueTint, greyTint, orangeTint]
  static let colorsNameToIndex = ["blue": 0, "purple": 1, "green": 2, "darkBlue": 3, "grey": 4, "orange": 5]
  
  static let minSec = 60
  static let hourSec = 60 * minSec
  static let daySec = dayHours * hourSec
  static let weekSec = 7 * daySec
  static let dayHours = 24
  static let weekHours = 7 * dayHours
  
  static let MinimumAlpha: CGFloat = 0.4
  
  static var moContext: NSManagedObjectContext {
    return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  }
  
  static var color: UIColor {
    return colors[colorIndex]
  }
  
  static var colorIndex: Int {
    get {
      if let color = NSUserDefaults.standardUserDefaults().objectForKey(colorSettingKey) {
        return colorsNameToIndex[color as! String]!
      } else {
        return 1
      }
    }
    set {
      for (name, index) in colorsNameToIndex {
        if index == newValue {
          NSUserDefaults.standardUserDefaults().setObject(name, forKey: colorSettingKey)
        }
      }
    }
  }
  
  static var notification: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(notificationSettingKey)
    }
    set {
      NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: notificationSettingKey)
    }
  }
  
  static var upcoming: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(upcomingSettingKey)
    }
    set {
      NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: upcomingSettingKey)
    }
  }
  
  static var startOfDay: NSTimeInterval {
    return 0 * 3600
  }
  
  static var endOfDay: NSTimeInterval {
    return 24 * 3600
  }
  
  static func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
      try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch let error as NSError {
      NSLog("error: \(error)")
    }
    
    let managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
  }
  
}
