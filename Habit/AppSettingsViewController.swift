//
//  AppSettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AppSettingsViewController: UIViewController, ColorPickerDataSource, ColorPickerDelegate {
  
  static let PanMinimum: CGFloat = 70
  
  var mvc: MainViewController?
  var darkenView: UIView?
  
  @IBOutlet weak var paddingView: UIView!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var colorPicker: ColorPicker!
  @IBOutlet weak var upcoming: UISwitch!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var autoSkip: UISwitch!
  @IBOutlet weak var autoSkipStepper: UIStepper!
  @IBOutlet weak var autoSkipDelay: UILabel!
  @IBOutlet weak var autoSkipHeight: NSLayoutConstraint!
  @IBOutlet weak var startOfDayStepper: UIStepper!
  @IBOutlet weak var startOfDayLabel: UILabel!
  @IBOutlet weak var endOfDayStepper: UIStepper!
  @IBOutlet weak var endOfDayLabel: UILabel!
  @IBOutlet weak var defaultAbbreviation: UILabel!
  @IBOutlet weak var defaultTimeZone: UILabel!
  @IBOutlet weak var local: UIView!
  @IBOutlet weak var localLabel: UILabel!
  @IBOutlet weak var localAbbreviation: UILabel!
  @IBOutlet weak var localTimeZone: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.ChevronDown), forState: .Normal)
    
    colorPicker.selectedIndex = HabitApp.colorIndex
    upcoming.on = HabitApp.upcoming
    notification.on = !HabitApp.notification
    autoSkip.on = HabitApp.autoSkip
    autoSkipStepper.value = Double(HabitApp.autoSkipDelay)
    autoSkipDelay.text = autoSkipDelayString(HabitApp.autoSkipDelay)
    if !autoSkip.on {
      autoSkipHeight.priority = HabitApp.LayoutPriorityLow
      view.layoutIfNeeded()
    }
    let timeZone = NSTimeZone(name: HabitApp.timeZone)!
    defaultTimeZone.text = timeZone.name.stringByReplacingOccurrencesOfString("_", withString: " ")
    defaultAbbreviation.text = timeZone.abbreviation!
    let localTZ = NSTimeZone.localTimeZone()
    if localTZ != timeZone {
      localAbbreviation.text = localTZ.abbreviation!
      localTimeZone.text = localTZ.name.stringByReplacingOccurrencesOfString("_", withString: " ")
    } else {
      local.removeFromSuperview()
      view.layoutIfNeeded()
    }
    startOfDayStepper.value = Double(HabitApp.startOfDay)
    startOfDayLabel.text = timeOfDayString(HabitApp.startOfDay)
    endOfDayStepper.value = Double(HabitApp.endOfDay)
    endOfDayLabel.text = timeOfDayString(HabitApp.endOfDay)
    setTimeOfDayMinMax()
    
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOpacity = 0.5
    view.layer.shadowRadius = 4
    view.layer.shadowOffset = CGSizeMake(0, -1)
    
    mvc = presentingViewController as? MainViewController
  }
  
  @IBAction func panning(recognizer: UIPanGestureRecognizer) {
    let movement = max(recognizer.translationInView(view).y, 0)
    view.frame = CGRectMake(0, movement, view.frame.width, view.frame.height)
    darkenView!.frame = CGRectMake(0, 0, view.frame.width, paddingView.bounds.height + movement)
    let panPercentage = 1 - movement / (view.frame.height - paddingView.bounds.height)
    darkenView!.alpha = panPercentage * AppSettingsTransition.DarkenAlpha
    close.alpha = max(1 - movement / AppSettingsViewController.PanMinimum, 0)
    
    if recognizer.state == .Ended || recognizer.state == .Cancelled {
      if movement < AppSettingsViewController.PanMinimum {
        UIView.animateWithDuration(AppSettingsTransition.TransitionDuration,
          delay: 0,
          usingSpringWithDamping: AppSettingsTransition.SpringDamping,
          initialSpringVelocity: AppSettingsTransition.SpringVelocity,
          options: AppSettingsTransition.AnimationOptions,
          animations: {
            self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            self.darkenView!.frame = CGRectMake(0, 0, self.view.frame.width, self.paddingView.bounds.height)
            self.darkenView!.alpha = AppSettingsTransition.DarkenAlpha
            self.close.alpha = 1
          }, completion: nil)
      } else {
        performSegueWithIdentifier("SettingsUnwind", sender: self)
      }
    }
  }
  
  func colorPicker(colorPicker: ColorPicker, colorAtIndex index: Int) -> UIColor {
    return HabitApp.colors[index]
  }
  
  func colorPicked(colorPicker: ColorPicker, colorIndex index: Int) {
    mvc!.changeColor(HabitApp.colors[index])
    HabitApp.colorIndex = index
  }
  
  @IBAction func upcomingChanged(sender: AnyObject) {
    HabitApp.upcoming = upcoming.on
    do {
      if upcoming.on {
        let request = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(request) as! [Habit]
        for habit in habits {
          habit.update(NSDate())
        }
      } else {
        let request = NSFetchRequest(entityName: "Entry")
        request.predicate = NSPredicate(
          format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)", Entry.State.Todo.rawValue, NSDate(), HabitApp.currentPeriods)
        let upcomingEntries = try HabitApp.moContext.executeFetchRequest(request)
        for entry in upcomingEntries {
          HabitApp.moContext.deleteObject(entry as! NSManagedObject)
        }
      }
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
    if !upcoming.on {
      mvc!.hideUpcoming()
    }
    mvc!.reloadEntries()    
    if upcoming.on {
      self.mvc!.showUpcoming()
    }
  }
  
  @IBAction func notificationChanged(sender: AnyObject) {
    HabitApp.notification = !notification.on
    if HabitApp.notification {
      mvc!.refreshNotifications()
    } else {
      UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
  }
  
  @IBAction func autoSkipChanged(sender: AnyObject) {
    if autoSkip.on {
      let darkenHeight = self.paddingView.bounds.height - self.autoSkipHeight.constant
      autoSkipHeight.priority = HabitApp.LayoutPriorityHigh
      UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
        animations: {
          self.darkenView!.frame = CGRectMake(0, 0, self.view.frame.width, darkenHeight)
          self.view.layoutIfNeeded()
        }, completion: { finished in
          HabitApp.autoSkip = true
      })
    } else {
      let darkenHeight = self.paddingView.bounds.height + self.autoSkipHeight.constant
      autoSkipHeight.priority = HabitApp.LayoutPriorityLow
      UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut,
        animations: {
          self.darkenView!.frame = CGRectMake(0, 0, self.view.frame.width, darkenHeight)
          self.view.layoutIfNeeded()
        }, completion: { finished in
          HabitApp.autoSkip = false
      })
    }
  }
  
  func autoSkipDelayString(delay: Int) -> String {
    if delay == 0 {
      return "immediately"
    } else {
      let hour = delay / 60
      var hourText = ""
      if hour == 1 {
        hourText = "1 hour "
      } else if hour > 1 {
        hourText = "\(hour) hours "
      }
      let minute = delay % 60
      var minuteText = ""
      if minute > 0 {
        minuteText = "\(minute) min"
      }
      return "\(hourText)\(minuteText)"
    }
  }
  
  @IBAction func autoSkipDelayChanged(sender: AnyObject) {
    autoSkipDelay.text = autoSkipDelayString(Int(autoSkipStepper.value))
    HabitApp.autoSkipDelay = Int(autoSkipStepper.value)
  }
  
  func timeOfDayString(time: Int) -> String {
    if time == 0 || time == HabitApp.dayMinutes {
      return "midnight"
    } else {
      let ampm = time < HabitApp.dayMinutes / 2 ? "a.m." : "p.m."
      var hour = (time / 60) % 12
      if hour == 0 {
        hour = 12
      }
      let minute = time % 60
      let minuteText = minute < 10 ? 0 : ""
      return "\(hour):\(minuteText)\(minute) \(ampm)"
    }
  }
  
  func setTimeOfDayMinMax() {
    startOfDayStepper.maximumValue = endOfDayStepper.value - 2 * 60.0
    endOfDayStepper.minimumValue = startOfDayStepper.value + 2 * 60.0
  }
  
  @IBAction func startOfDayChanged(sender: AnyObject) {
    startOfDayLabel.text = timeOfDayString(Int(startOfDayStepper.value))
    setTimeOfDayMinMax()
  }
  
  @IBAction func endOfDayChanged(sender: AnyObject) {
    endOfDayLabel.text = timeOfDayString(Int(endOfDayStepper.value))
    setTimeOfDayMinMax()
  }
  
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    let newStart = HabitApp.startOfDay != Int(startOfDayStepper.value)
    let newEnd =  HabitApp.endOfDay != Int(endOfDayStepper.value)
    if newStart || newEnd {
      var problemHabits: [String] = []
      do {
        let request = NSFetchRequest(entityName: "Habit")
        let habits = try HabitApp.moContext.executeFetchRequest(request) as! [Habit]
        for habit in habits {
          switch habit.frequency {
          case .Daily:
            if habit.useTimes {
              problemHabits.append("\(habit.name!): interval between due times will change")
            } else {
              problemHabits.append("\(habit.name!): someting will fail")
            }
          case .Weekly:
            if habit.useTimes {
              problemHabits.append("\(habit.name!): ")
            } else {
              problemHabits.append("\(habit.name!): due time changed to new end of day")
            }
          case .Monthly:
            if newEnd {
              problemHabits.append("\(habit.name!): due time changed to new end of day")
            }
          default: ()
          }
          if habit.frequency == .Daily {
            
          }
          habit.update(NSDate())
        }
      } catch let error as NSError {
        NSLog("Fetch failed: \(error.localizedDescription)")
      }
      if problemHabits.count > 0 {
        let alert = UIAlertController(title: "Warning", message: problemHabits.joinWithSeparator("\n"), preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Confirm", style: .Destructive, handler: { (action) in
          HabitApp.startOfDay = Int(self.startOfDayStepper.value)
          HabitApp.endOfDay = Int(self.endOfDayStepper.value)
          do {
            // Do batch delete from ios9
            let entryRequest = NSFetchRequest(entityName: "Entry")
            entryRequest.predicate = NSPredicate(format: "due > %@", NSDate())
            let entries = try HabitApp.moContext.executeFetchRequest(entryRequest) as! [Entry]
            for entry in entries {
              HabitApp.moContext.deleteObject(entry)
            }
            let habitRequest = NSFetchRequest(entityName: "Habit")
            let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
            for habit in habits {
              habit.update(NSDate())
            }
            try HabitApp.moContext.save()
          } catch let error as NSError {
            NSLog("Fetch failed: \(error.localizedDescription)")
          }
          self.performSegueWithIdentifier("SettingsUnwind", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) in
          self.performSegueWithIdentifier("SettingsUnwind", sender: self)
        }))
        presentViewController(alert, animated: true, completion: nil)
        return false
      }
    }
    return true
  }
  
}
