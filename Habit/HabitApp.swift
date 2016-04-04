//
//  HabitApp.swift
//  Habit
//
//  Created by harry on 7/23/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData

class HabitApp {
  
  // User setting strings
  static let timeZoneSettingKey = "timezone"
  static let notificationSettingKey = "notification"
  static let colorSettingKey = "color"
  static let upcomingSettingKey = "upcoming"
  static let autoSkipSettingKey = "autoskip"
  static let autoSkipDelaySettingKey = "autoskipdelay"
  static let startOfDayKey = "startofday"
  static let endOfDayKey = "endofday"
  
  static let calendar: NSCalendar = {
    let c = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    c.timeZone = NSTimeZone(name: HabitApp.timeZone)!
    return c
  }()
  
  static var managedObjectContext: NSManagedObjectContext?
  
  static var moContext: NSManagedObjectContext {
    return managedObjectContext!
  }
  
  static var color: UIColor {
    return Constants.colors[colorIndex]
  }
  
  static var colorIndex: Int {
    get {
      if let color = NSUserDefaults.standardUserDefaults().objectForKey(colorSettingKey) {
        return Constants.colorsNameToIndex[color as! String]!
      } else {
        return 1
      }
    }
    set {
      for (name, index) in Constants.colorsNameToIndex {
        if index == newValue {
          NSUserDefaults.standardUserDefaults().setObject(name, forKey: colorSettingKey)
        }
      }
    }
  }
  
  static var notification: Bool {
    get { return NSUserDefaults.standardUserDefaults().boolForKey(notificationSettingKey) }
    set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: notificationSettingKey) }
  }
  
  static var upcoming: Bool {
    get { return NSUserDefaults.standardUserDefaults().boolForKey(upcomingSettingKey) }
    set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: upcomingSettingKey) }
  }
  
  static var autoSkip: Bool {
    get { return NSUserDefaults.standardUserDefaults().boolForKey(autoSkipSettingKey) }
    set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: autoSkipSettingKey) }
  }
  
  static var autoSkipDelay: Int {
    get { return NSUserDefaults.standardUserDefaults().integerForKey(autoSkipDelaySettingKey) }
    set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: autoSkipDelaySettingKey) }
  }
  
  static var autoSkipDelayTimeInterval: NSTimeInterval { return NSTimeInterval(Constants.minSec * autoSkipDelay) }
  
  static var timeZone: String {
    get {
      if let tz = NSUserDefaults.standardUserDefaults().stringForKey(timeZoneSettingKey) {
        return tz
      } else {
        return ""
      }
    }
    set { NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: timeZoneSettingKey) }
  }
  
  static var startOfDay: Int {
    get { return NSUserDefaults.standardUserDefaults().integerForKey(startOfDayKey) }
    set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: startOfDayKey) }
  }
  
  static var endOfDay: Int {
    get { return NSUserDefaults.standardUserDefaults().integerForKey(endOfDayKey) }
    set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: endOfDayKey) }
  }
  
  static func setupAppManagedObjectContext() {
    managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  }
  
  static func setUpInMemoryManagedObjectContext() {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
      try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch let error as NSError {
      NSLog("error: \(error)")
    }
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
  }
  
  static func initNotification() {
    let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
    if !(settings!.types.contains(.Badge) && settings!.types.contains(.Sound) && settings!.types.contains(.Alert)) {
      let completeAction = UIMutableUserNotificationAction()
      completeAction.identifier = "COMPLETE"
      completeAction.title = "Complete"
      completeAction.activationMode = .Background
      completeAction.authenticationRequired = false
      completeAction.destructive = false
      
      let skipAction = UIMutableUserNotificationAction()
      skipAction.identifier = "SKIP"
      skipAction.title = "Skip"
      skipAction.activationMode = .Background
      skipAction.authenticationRequired = false
      skipAction.destructive = false
      
      let habitCategory = UIMutableUserNotificationCategory()
      habitCategory.identifier = "HABIT_CATEGORY"
      habitCategory.setActions([completeAction, skipAction], forContext: .Minimal)
      
      let notificationSettings =
        UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: [habitCategory])
      UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
  }
  
  static func currentPeriods() -> [String] {
    return currentPeriods(NSDate())
  }
  
  static func currentPeriods(now: NSDate) -> [String] {
    return [
      "Daily\(HabitApp.calendar.components([.Day], fromDate: now).day)",
      "Weekly\(HabitApp.calendar.components([.WeekOfYear], fromDate: now).weekOfYear)",
      "Monthly\(HabitApp.calendar.components([.Month], fromDate: now).month)"
    ]
  }
  
  static var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    formatter.timeZone = NSTimeZone(abbreviation: "PST")
    return formatter
  }()
  
  enum PhoneSize {
    case iPhone4, iPhone5, iPhone6, iPhone6P
  }
  
  static var phoneSize: PhoneSize = {
    switch UIScreen.mainScreen().scale {
    case 2.0:
      switch UIScreen.mainScreen().bounds.size.height {
      case 667:
        return .iPhone6
      case 568:
        return .iPhone5
      default:
        return .iPhone4
      }
    default: // 3.0
      return .iPhone6P // 736.0
    }
  }()
  
}
