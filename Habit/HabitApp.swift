//
//  HabitApp.swift
//  Habit
//
//  Created by harry on 7/23/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

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
    let c = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
    c.timeZone = TimeZone(identifier: HabitApp.timeZone)!
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
      if let color = UserDefaults.standard.object(forKey: colorSettingKey) {
        return Constants.colorsNameToIndex[color as! String]!
      } else {
        return 1
      }
    }
    set {
      for (name, index) in Constants.colorsNameToIndex {
        if index == newValue {
          UserDefaults.standard.set(name, forKey: colorSettingKey)
        }
      }
    }
  }
  
  static var notification: Bool {
    get { return UserDefaults.standard.bool(forKey: notificationSettingKey) }
    set { UserDefaults.standard.set(newValue, forKey: notificationSettingKey) }
  }
  
  static var upcoming: Bool {
    get { return UserDefaults.standard.bool(forKey: upcomingSettingKey) }
    set { UserDefaults.standard.set(newValue, forKey: upcomingSettingKey) }
  }
  
  static var autoSkip: Bool {
    get { return UserDefaults.standard.bool(forKey: autoSkipSettingKey) }
    set { UserDefaults.standard.set(newValue, forKey: autoSkipSettingKey) }
  }
  
  static var autoSkipDelay: Int {
    get { return UserDefaults.standard.integer(forKey: autoSkipDelaySettingKey) }
    set { UserDefaults.standard.set(newValue, forKey: autoSkipDelaySettingKey) }
  }
  
  static var autoSkipDelayTimeInterval: TimeInterval { return TimeInterval(Constants.minSec * autoSkipDelay) }
  
  static var timeZone: String {
    get {
      if let tz = UserDefaults.standard.string(forKey: timeZoneSettingKey) {
        return tz
      } else {
        return ""
      }
    }
    set { UserDefaults.standard.set(newValue, forKey: timeZoneSettingKey) }
  }
  
  static var startOfDay: Int {
    get { return UserDefaults.standard.integer(forKey: startOfDayKey) }
    set { UserDefaults.standard.set(newValue, forKey: startOfDayKey) }
  }
  
  static var endOfDay: Int {
    get { return UserDefaults.standard.integer(forKey: endOfDayKey) }
    set { UserDefaults.standard.set(newValue, forKey: endOfDayKey) }
  }
  
  static func setupAppManagedObjectContext() {
    managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  }
  
  static func setUpInMemoryManagedObjectContext() {
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
      try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch let error as NSError {
      NSLog("error: \(error)")
    }
    
    managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
  }
  
  static func initNotification() {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      if !(settings.badgeSetting == .enabled && settings.soundSetting == .enabled && settings.alertSetting == .enabled) {
        let completeAction = UNNotificationAction(identifier: "COMPLETE",
                                                  title: "Complete",
                                                  options: [.destructive, .authenticationRequired])
        let skipAction = UNNotificationAction(identifier: "SKIP",
                                              title: "Skip",
                                              options: [.destructive, .authenticationRequired])
        let habitCategory = UNNotificationCategory(identifier: "HABIT_CATEGORY",
                                                   actions: [completeAction, skipAction],
                                                   intentIdentifiers: []);
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([habitCategory])
        center.requestAuthorization(options: [.badge, .sound, .alert]) {
          (granted, error) in
          //Parse errors and track state
        }
      }
    }
  }
  
  static func currentPeriods() -> [String] {
    return currentPeriods(now: Date())
  }
  
  static func currentPeriods(now: Date) -> [String] {
    return [
      "Daily\(HabitApp.calendar.components([.day], from: now).day!)",
      "Weekly\(HabitApp.calendar.components([.weekOfYear], from: now).weekOfYear!)",
      "Monthly\(HabitApp.calendar.components([.month], from: now).month!)"
    ]
  }
  
  static var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    formatter.timeZone = TimeZone(abbreviation: "PST")
    return formatter
  }()
  
  enum PhoneSize {
    case iPhone4, iPhone5, iPhone6, iPhone6P
  }
  
  static var phoneSize: PhoneSize = {
    switch UIScreen.main.scale {
    case 2.0:
      switch UIScreen.main.bounds.size.height {
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
