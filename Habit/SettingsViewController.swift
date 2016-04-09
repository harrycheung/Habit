//
//  SettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
  
  let PanMinimum: CGFloat = 0.5
  
  var mvc: MainViewController!
  var darkenView: UIView!
  
  @IBOutlet weak var blurView: UIView!
  @IBOutlet weak var settingsView: UIView!
  @IBOutlet weak var slideConstraint: NSLayoutConstraint!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var colorPicker: ColorPicker!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var autoSkip: UISwitch!
  @IBOutlet weak var autoSkipStepper: UIStepper!
  @IBOutlet weak var autoSkipDelay: UILabel!
  @IBOutlet weak var autoSkipView: UIView!
  @IBOutlet weak var startOfDayStepper: UIStepper!
  @IBOutlet weak var startOfDayLabel: UILabel!
  @IBOutlet weak var endOfDayStepper: UIStepper!
  @IBOutlet weak var endOfDayLabel: UILabel!
  @IBOutlet weak var defaultAbbreviation: UILabel!
  @IBOutlet weak var defaultTimeZone: UILabel!
  @IBOutlet weak var local: UIView!
  @IBOutlet weak var localAbbreviation: UILabel!
  @IBOutlet weak var localTimeZone: UILabel!
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.ChevronDown), forState: .Normal)
    
    colorPicker.delegate = self
    colorPicker.configure(Constants.colors)
    colorPicker.selectedIndex = HabitApp.colorIndex
    notification.on = !HabitApp.notification
    autoSkip.on = HabitApp.autoSkip
    autoSkipStepper.value = Double(HabitApp.autoSkipDelay)
    autoSkipDelay.text = autoSkipDelayString(HabitApp.autoSkipDelay)
    if !autoSkip.on {
      autoSkipView.hidden = true
      autoSkipView.alpha = 0
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
    
    slideConstraint.priority = Constants.LayoutPriorityLow
    view.layoutIfNeeded()
  }
  
  @IBAction func panning(recognizer: UIPanGestureRecognizer) {
    let movement = max(recognizer.translationInView(view).y, 0)
    settingsView.frame = CGRectMake(0, movement + settingsView.frame.origin.y,
                                    settingsView.frame.width, settingsView.frame.height)
    let panPercentage = movement / settingsView.frame.height
    close.alpha = max(1 - panPercentage / PanMinimum, 0)

    if recognizer.state == .Ended || recognizer.state == .Cancelled {
      if panPercentage < PanMinimum {
        UIView.animateWithDuration(SettingsTransition.TransitionDuration,
          delay: 0,
          usingSpringWithDamping: SettingsTransition.SpringDamping,
          initialSpringVelocity: SettingsTransition.SpringVelocity,
          options: SettingsTransition.AnimationOptions,
          animations: {
            self.settingsView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            self.close.alpha = 1
          }, completion: nil)
      } else {
        closeSettings(recognizer)
      }
    }
  }
  
  @IBAction func notificationChanged(sender: AnyObject) {
    HabitApp.notification = !notification.on
    if HabitApp.notification {
      HabitManager.updateNotifications()
    } else {
      UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
  }
  
  @IBAction func autoSkipChanged(sender: AnyObject) {
    if autoSkip.on {
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 delay: 0,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.autoSkipView.hidden = false
                                  self.autoSkipView.alpha = 1
                                 },
                                 completion: nil)
    } else {
      UIView.animateWithDuration(Constants.TransitionDuration,
                                 delay: 0,
                                 options: .CurveEaseOut,
                                 animations: {
                                  self.autoSkipView.hidden = true
                                  self.autoSkipView.alpha = 0
                                 },
                                 completion: nil)
    }
  }
  
  func autoSkipDelayString(delay: Int) -> String {
    if delay == 0 {
      return "Immediately"
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
        minuteText = "\(minute) min "
      }
      return "\(hourText)\(minuteText)past due"
    }
  }
  
  @IBAction func autoSkipDelayChanged(sender: AnyObject) {
    autoSkipDelay.text = autoSkipDelayString(Int(autoSkipStepper.value))
    HabitApp.autoSkipDelay = Int(autoSkipStepper.value)
  }
  
  func timeOfDayString(time: Int) -> String {
    if time == 0 || time == Constants.dayMinutes {
      return "midnight"
    } else {
      let ampm = time < Constants.dayMinutes / 2 ? "a.m." : "p.m."
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
  
  @IBAction func closeSettings(sender: AnyObject) {
    let dayAlert = { () -> Void in
      let newStart = HabitApp.startOfDay != Int(self.startOfDayStepper.value)
      let newEnd = HabitApp.endOfDay != Int(self.endOfDayStepper.value)
      if newStart || newEnd {
        var timing = ""
        if newStart && newEnd {
          timing = "start/end of day times"
        } else if newStart {
          timing = "start of day time"
        } else {
          timing = "end of day time"
        }
        let alert = UIAlertController(title: "Start/End of Day Adjusted",
          message: "Entries after today will be adjusted\nwith new \(timing).\nThis can't be undone.",
          preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .Default, handler: { action in
          HabitApp.startOfDay = Int(self.startOfDayStepper.value)
          HabitApp.endOfDay = Int(self.endOfDayStepper.value)
          self.mvc!.resetFuture()
        }))
        self.mvc!.presentViewController(alert, animated: true, completion: nil)
      }
    }
    
    let autoSkipAlert = { () -> Void in
      if self.autoSkip.on && self.autoSkip.on != HabitApp.autoSkip && HabitManager.overdue > 0 {
        let alert = UIAlertController(title: "Automatic Skip Enabled",
          message: "Would you like to skip the\n\(HabitManager.overdue) overdue habit entries.\nThis can't be undone.",
          preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "No", style: .Destructive, handler: { action in
          HabitApp.autoSkip = true
          dayAlert()
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
          HabitApp.autoSkip = true
          self.mvc!.deleteRows(HabitManager.skip()) {
            dayAlert()
          }
        }))
        self.mvc!.presentViewController(alert, animated: true, completion: nil)
      } else {
        HabitApp.autoSkip = self.autoSkip.on
        dayAlert()
      }
    }
    
    self.dismissViewControllerAnimated(true) {
      autoSkipAlert()
    }
  }
  
}

extension SettingsViewController: ColorPickerDelegate {
  
  func colorPicked(colorPicker: ColorPicker, colorIndex index: Int) {
    mvc.changeColor(Constants.colors[index])
    HabitApp.colorIndex = index
  }
  
}
