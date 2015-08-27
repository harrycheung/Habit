//
//  HabitSettingsViewController.swift
//  Habit
//
//  Created by harry on 8/14/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import SnapKit
import KAProgressLabel
import FontAwesome_swift

class HabitSettingsViewController: UIViewController, UITextFieldDelegate, FrequencySettingsDelegate, UIGestureRecognizerDelegate {
  
  let UnwindSegueIdentifier = "HabitSettingsUnwind"
  
  var habit: Habit?
  var frequencySettings = [FrequencySettings?](count:3, repeatedValue: nil)
  var pickerRecognizers = [UITapGestureRecognizer?](count:3, repeatedValue: nil)
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var switchMode: UIButton!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var toolbar: UIView!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var height: NSLayoutConstraint!
  
  var activeSettings: FrequencySettings {
    return frequencySettings[frequency.selectedSegmentIndex]!
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup settings views for each frequency
    frequencySettings[0] = FrequencySettings(leftTitle: "Times a day",
      pickerCount: 12,
      rightTitle: "Parts of day",
      multiSelectItems: ["Morning", "Mid-Morning", "Midday", "Afternoon", "Late Afternoon", "Evening"],
      useTimes: habit!.useTimes,
      delegate: self)
    buildSettings(frequencySettings[0]!, centerX: 0.33333)
    frequencySettings[1] = FrequencySettings(leftTitle: "Times a week",
      pickerCount: 6,
      rightTitle: "Days of week",
      multiSelectItems: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      useTimes: habit!.useTimes,
      delegate: self)
    buildSettings(frequencySettings[1]!, centerX: 1)
    frequencySettings[2] = FrequencySettings(leftTitle: "Times a month",
      pickerCount: 5,
      rightTitle: "Parts of month",
      multiSelectItems: ["Beginning", "Middle", "End"],
      useTimes: habit!.useTimes,
      delegate: self)
    buildSettings(frequencySettings[2]!, centerX: 1.66666)
    
    // Fill out the form
    name.text = habit!.name;
    name.delegate = self
    frequency.selectedSegmentIndex = habit!.frequencyRaw!.integerValue - 1
    if habit!.useTimes {
      activeSettings.picker.selectRow(habit!.times!.integerValue - 1, inComponent: 0, animated: false)
    } else {
      activeSettings.multiSelect.selectedIndexes = habit!.partsArray.map { $0 - 1 }
    }
    notification.on = habit!.notifyBool
    
    // Tap handlers for closing the keyboard. Note: I need a specific recognizer for
    // the UIPickerViews since they handle the gesture a little differently. I think
    // it's a bug.
    let recognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    for index in 0..<3 {
      pickerRecognizers[index] = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
      pickerRecognizers[index]!.cancelsTouchesInView = false
      pickerRecognizers[index]!.numberOfTapsRequired = 1
      pickerRecognizers[index]!.delegate = self
      frequencySettings[index]!.picker.addGestureRecognizer(pickerRecognizers[index]!)
    }
    
    // Setup form if this is new
    if habit!.isNew {
      save.setTitle("Create", forState: .Normal)
      switchMode.hidden = true
      deleteWidth.priority = 999 //UILayoutPriorityDefaultHigh
      
      let blur = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
      let content = view.subviews[0]
      blur.contentView.addSubview(content)
      content.snp_makeConstraints({ (make) in
        make.centerY.equalTo(blur.contentView)
        make.left.equalTo(blur.contentView).offset(8)
        make.right.equalTo(blur.contentView).offset(-8)
      })
      view.addSubview(blur)
      blur.snp_makeConstraints({ (make) in
        make.edges.equalTo(view)
      })
    } else {
      switchMode.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
      switchMode.setTitle(String.fontAwesomeIconWithName(.Close), forState: .Normal)
      back.hidden = true
    }
    
    back.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    back.setTitle(String.fontAwesomeIconWithName(.ChevronLeft), forState: .Normal)
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    UIApplication.sharedApplication().keyWindow!.tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    red += (1 - red) * 0.8
    green += (1 - green) * 0.8
    blue += (1 - blue) * 0.8
    toolbar.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollToSettings(frequency.selectedSegmentIndex)
  }
  
  func buildSettings(settings: FrequencySettings, centerX: CGFloat) {
    settings.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(settings)
    settings.snp_makeConstraints {(make) in
      make.centerX.equalTo(frequencyScrollerContent).multipliedBy(centerX)
      make.centerY.equalTo(frequencyScrollerContent)
      make.width.equalTo(frequencyScrollerContent).multipliedBy(0.33333)
      make.height.equalTo(frequencyScrollerContent)
    }
  }
  
  @IBAction func frequencyChanged(sender: AnyObject) {
    scrollToSettings(frequency.selectedSegmentIndex, animated: true)
    enableSave()
  }
  
  func frequencySettingsChanged() {
    enableSave()
  }
  
  @IBAction func notifyChanged(sender: AnyObject) {
    enableSave()
  }
  
  @IBAction func nameChanged(sender: AnyObject) {
    enableSave()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      for recognizer in pickerRecognizers {
        if recognizer!.isEqual(gestureRecognizer) {
          return true
        }
      }
      return false
  }
  
  func hideKeyboard(recognizer: UIPanGestureRecognizer) {
    // TODO: or name.resignFirstResponder?
    view.endEditing(true)
  }
  
  func scrollToSettings(index: Int, animated: Bool = false) {
    let bounds = frequencyScroller.bounds
    frequencyScroller.scrollRectToVisible(
      CGRectMake(CGFloat(index) * bounds.width, 0, bounds.width, bounds.height), animated: animated)
  }
  
  func enableSave() {
    let settings = activeSettings
    if !habit!.isNew && name.text! == habit!.name! && notification.on == habit!.notifyBool &&
      frequency.selectedSegmentIndex == habit!.frequencyRaw!.integerValue - 1 {
        // If name and frequency is the same, test frequency settings
        save.enabled = (settings.useTimes &&
          (!habit!.useTimes || settings.picker.selectedRowInComponent(0) != habit!.timesInt - 1)) ||
          (!settings.useTimes && !settings.multiSelect.selectedIndexes.isEmpty &&
            (habit!.useTimes || settings.multiSelect.selectedIndexes != habit!.partsArray.map { $0 - 1 } ))
    } else {
      // If either name or frequency is different, check frequency settings too
      save.enabled = !name.text!.isEmpty
      if !settings.useTimes {
        save.enabled = save.enabled && !settings.multiSelect.selectedIndexes.isEmpty
      }
    }
  }
  
  @IBAction func closeView(sender: AnyObject) {
    if habit!.isNew {
      HabitApp.moContext.deleteObject(habit!)
      habit = nil
    }
    performSegueWithIdentifier(UnwindSegueIdentifier, sender: self)
  }
  
  @IBAction func saveHabit(sender: AnyObject) {
    // TODO: set habit!.next
    habit!.name = name.text!
    habit!.frequencyRaw = frequency.selectedSegmentIndex + 1
    if activeSettings.useTimes {
      habit!.times = activeSettings.picker!.selectedRowInComponent(0) + 1
      habit!.partsArray = []
    } else {
      habit!.partsArray = activeSettings.multiSelect.selectedIndexes
    }
    habit!.notifyBool = notification.on
    if habit!.isNew {
      habit!.last = NSDate()
      habit!.createdAt = NSDate()
    }
    habit!.update(NSDate())
    do {
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    }
    
    if notification.on {
      //      if UIApplication.sharedApplication().currentUserNotificationSettings()!.types.contains(.Alert) {
      //        let local = UILocalNotification()
      //        local.fireDate = NSDate(timeIntervalSinceNow: 10)//habit!.dueIn)
      //        local.alertAction = "Time to habit!"
      //        local.alertBody = habit!.name
      //        //UIApplication.sharedApplication().presentLocalNotificationNow(local)
      //        UIApplication.sharedApplication().scheduleLocalNotification(local)
      //      }
    }
    
    performSegueWithIdentifier(UnwindSegueIdentifier, sender: self)
  }
  
  @IBAction func deleteHabit(sender: AnyObject) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let delete = UIAlertAction(title: "Delete habit", style: .Destructive, handler: { (UIAlertAction) in
      HabitApp.moContext.deleteObject(self.habit!)
      do {
        try HabitApp.moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      } catch {
        // something
      }
      self.habit = nil
      self.presentingViewController!.view.hidden = true
//      self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
      self.performSegueWithIdentifier(self.UnwindSegueIdentifier, sender: self)
    })
    alert.addAction(delete)
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) in
      alert.dismissViewControllerAnimated(true, completion: nil)
    })
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion: nil)
  }
  
}
