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
  static let pinkTint = UIColor(red: 231.0 / 255.0, green: 84.0 / 255.0, blue: 128.0 / 255.0, alpha: 1)
  static let darkBlueTint = UIColor(red: 52.0 / 255.0, green: 73.0 / 255.0, blue: 120.0 / 255.0, alpha: 1)
  static let redTint = UIColor(red: 192.0 / 255.0, green: 57.0 / 255.0, blue: 42.0 / 255.0, alpha: 1)
  static let orangeTint = UIColor(red: 255.0 / 255.0, green: 140.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
  static let colors = [purpleTint, darkBlueTint, blueTint, orangeTint, pinkTint, redTint]
  static let colorsNameToIndex = ["purple": 0, "darkBlue": 1, "blue": 2, "orange": 3, "pink": 4, "red": 5]
  
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
  static let NewButtonFadeAnimationDuration: NSTimeInterval = 0.2
  static let LayoutPriorityLow: UILayoutPriority = 900
  static let LayoutPriorityHigh: UILayoutPriority = 999
  static let TransitionOverlayAlpha: CGFloat = 0.2
  static let TransitionDuration: NSTimeInterval = 0.25
  
  static let calendar: NSCalendar = {
    let c = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    c.timeZone = NSTimeZone(name: HabitApp.timeZone)!
    return c
  }()
  
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
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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
  
  static func addNotification(entry: Entry, number: Int) {
    if HabitApp.notification {
      if UIApplication.sharedApplication().currentUserNotificationSettings()!.types.contains(.Alert) {
        let local = UILocalNotification()
        local.fireDate = entry.due
        local.alertBody = entry.habit!.name!
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
