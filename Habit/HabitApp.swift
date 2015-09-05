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
  static let autoSkipSettingKey = "autoskip"
  static let autoSkipDelaySettingKey = "autoskipdelay"
  static let startOfDayKey = "startofday"
  static let endOfDayKey = "endofday"
  
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
  static let dayMinutes = hourMinutes * dayHours
  static let dayHours = 24
  static let hourMinutes = 60
  static let weekMinutes = 7 * dayMinutes
  static let weekHours = 7 * dayHours
  
  static let MinimumAlpha: CGFloat = 0.4
  static let NewButtonAnimationDuration: NSTimeInterval = 0.2
  static let LayoutPriorityLow: UILayoutPriority = 900
  static let LayoutPriorityHigh: UILayoutPriority = 999
  
  static let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
  
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
  
  static var autoSkipDelayTimeInterval: NSTimeInterval { return NSTimeInterval(HabitApp.minSec * autoSkipDelay) }
  
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
  
  static var overdueCount: Int {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND due < %@", Entry.State.Todo.rawValue, NSDate())
      let r = try HabitApp.moContext.executeFetchRequest(request)
      return r.count
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
      return 0
    }
  }
  
  static func addNotification(entry: Entry, number: Int) {
    if HabitApp.notification {
      if UIApplication.sharedApplication().currentUserNotificationSettings()!.types.contains(.Alert) {
        let local = UILocalNotification()
        local.fireDate = entry.due
        local.alertBody = entry.habit!.name! + " \(number)"
        local.userInfo = ["entry": entry.objectID.URIRepresentation().absoluteString]
        local.applicationIconBadgeNumber = number
        local.soundName = UILocalNotificationDefaultSoundName
        local.category = "HABIT_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(local)
      }
    }
  }
  
  static func removeNotification(entry: Entry) {
    if HabitApp.notification {
      if let notification = hasNotification(entry) {
        UIApplication.sharedApplication().cancelLocalNotification(notification)
      }
    }
  }
  
  static func hasNotification(entry: Entry) -> UILocalNotification? {
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
      if notification.userInfo!["entry"] as! String == entry.objectID.URIRepresentation().absoluteString {
        return notification
      }
    }
    return nil
  }
  
  static var currentPeriods: [String] {
    let now = NSDate()
    return [
      "Daily\(HabitApp.calendar.components([.Day], fromDate: now).day)",
      "Weekly\(HabitApp.calendar.components([.WeekOfYear], fromDate: now).weekOfYear)",
      "Monthly\(HabitApp.calendar.components([.Month], fromDate: now).month)"
    ]
  }
  
}
