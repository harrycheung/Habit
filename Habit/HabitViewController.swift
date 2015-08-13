//
//  HabitViewController.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SnapKit
import KAProgressLabel
import FontAwesome_swift

class HabitViewController : UIViewController, UITextFieldDelegate, FrequencySettingsDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, HabitHistoryDelegate {
  
  let UnwindSegueIdentifier = "HabitUnwind"
  let AnimateSwitchModeDuration = 0.4
  let MaxPriority: UILayoutPriority = 999
  let MinPriority: UILayoutPriority = 997
  
  var habit: Habit?
  var frequencySettings = [FrequencySettings?](count:3, repeatedValue: nil)
  var pickerRecognizers = [UITapGestureRecognizer?](count:3, repeatedValue: nil)
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var nameTrailing: NSLayoutConstraint!
  @IBOutlet weak var switchMode: UIButton!
  @IBOutlet weak var settings: UIView!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var progressLabel: KAProgressLabel!
  @IBOutlet weak var progressPercentage: UILabel!
  @IBOutlet weak var progressPeriod: UILabel!
  @IBOutlet weak var statsView: UIView!
  @IBOutlet weak var statsHeight: NSLayoutConstraint!
  @IBOutlet weak var settingsHeight: NSLayoutConstraint!
  @IBOutlet weak var settingsView: UIView!
  @IBOutlet weak var toolbar: UIView!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var currentStreak: UILabel!
  @IBOutlet weak var longestStreak: UILabel!
  @IBOutlet weak var skipped: UILabel!
  @IBOutlet weak var completed: UILabel!
  @IBOutlet weak var habitHistory: HabitHistory!
  
  var activeSettings: FrequencySettings {
    return frequencySettings[frequency.selectedSegmentIndex]!
  }
  
  struct AnimationNumbers {
    var completedStart: Int = 0
    var completedEnd: Int = 0
    var percentageStart: CGFloat = 0
    var percentageEnd: CGFloat = 0
    var skippedStart: Int = 0
    var skippedEnd: Int = 0
  }
  var animationNumbers = AnimationNumbers()
  
  func animateNumbers(progress: CGFloat) {
    let percentage = CGFloat(progress - animationNumbers.percentageStart) / CGFloat(animationNumbers.percentageEnd - animationNumbers.percentageStart)
    let currentCompleted = CGFloat(animationNumbers.completedEnd - animationNumbers.completedStart) * percentage + CGFloat(animationNumbers.completedStart)
    let currentSkipped = CGFloat(animationNumbers.skippedEnd - animationNumbers.skippedStart) * percentage + CGFloat(animationNumbers.skippedStart)
    if currentCompleted.isNormal {
      completed.text = "\(Int(currentCompleted))"
    }
    if currentSkipped.isNormal {
      skipped.text = "\(Int(currentSkipped))"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    progressLabel.labelVCBlock = { (label) in
      self.progressPercentage.text = "\(Int(label.progress * 100))%"
      self.animateNumbers(label.progress)
    }
    progressLabel.progressColor = HabitApp.color
    
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
    frequency.selectedSegmentIndex = habit!.frequencyNum!.integerValue - 1
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
      deleteWidth.priority = UILayoutPriorityDefaultHigh
      statsView.hidden = true
      statsHeight.priority = MinPriority
      settingsView.hidden = false
      settingsView.alpha = 1
      settingsHeight.priority = MaxPriority
    } else {
      switchMode.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
      switchMode.setTitle(String.fontAwesomeIconWithName(.Cog), forState: .Normal)
    }
    
    back.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    back.setTitle(String.fontAwesomeIconWithName(.ChevronLeft), forState: .Normal)
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    UIApplication.sharedApplication().keyWindow!.tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    red += (1 - red) * 0.8
    green += (1 - green) * 0.8
    blue += (1 - blue) * 0.8
    toolbar.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    
    habitHistory.habit = habit!
  }
  
  override func viewWillAppear(animated: Bool) {
    setupStats()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollToSettings(frequency.selectedSegmentIndex)
  }
  
  func setupStats() {
    currentStreak.text = "\(habit!.currentStreak!)"
    longestStreak.text = "\(habit!.longestStreak!)"
    skipped.text = "\(habit!.skippedCount())"
    completed.text = "\(habit!.completedCount())"
    
    switch habit!.frequency {
    case .Daily:
      progressPeriod.text = "Past 30 days"
      break
    case .Weekly:
      progressPeriod.text = "Past 12 weeks"
      break
    case .Monthly:
      progressPeriod.text = "Past 6 months"
      break
    default: ()
    }
    progressLabel.setProgress(habit!.progress(), timing: TPPropertyAnimationTimingEaseOut, duration: 0.5, delay: 0.3)
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
  
  func changeMode(fromView fromView: UIView, fromHeight: NSLayoutConstraint,
    toView: UIView, toHeight: NSLayoutConstraint, switchModeIcon: FontAwesome) {
    fromView.hidden = true
    fromHeight.priority = MinPriority
    toView.hidden = false
    toHeight.priority = MaxPriority
    UIView.animateWithDuration(AnimateSwitchModeDuration, animations: {
      fromView.alpha = 0
      toView.alpha = 1
      self.view.layoutIfNeeded()
    })
    UIView.animateWithDuration(AnimateSwitchModeDuration / 2, animations: {
      self.switchMode.alpha = 0
    }, completion: { (finished) in
      self.switchMode.setTitle(String.fontAwesomeIconWithName(switchModeIcon), forState: .Normal)
      UIView.animateWithDuration(self.AnimateSwitchModeDuration / 2, animations: {
        self.switchMode.alpha = 1
      })
    })
  }
  
  @IBAction func changeMode(sender: AnyObject) {
    if statsView.hidden {
      changeMode(fromView: settingsView, fromHeight: settingsHeight,
        toView: statsView, toHeight: statsHeight, switchModeIcon: .Cog)
    } else {
      changeMode(fromView: statsView, fromHeight: statsHeight,
        toView: settingsView, toHeight: settingsHeight, switchModeIcon: .Close)
    }
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
       frequency.selectedSegmentIndex == habit!.frequencyNum!.integerValue - 1 {
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
    habit!.frequencyNum = frequency.selectedSegmentIndex + 1
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
    habit!.updateNext(NSDate())
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
      self.performSegueWithIdentifier(self.UnwindSegueIdentifier, sender: self)
    })
    alert.addAction(delete)
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) in
      alert.dismissViewControllerAnimated(true, completion: nil)
    })
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // HabitHistory
  
  func habitHistory(habitHistory: HabitHistory, selectedHistory history: History) {
    progressLabel.setProgress(history.percentage, timing: TPPropertyAnimationTimingEaseOut, duration: 0.5, delay: 0)
    animationNumbers.percentageStart = progressLabel.progress
    animationNumbers.percentageEnd = history.percentage
    animationNumbers.completedStart = Int(completed.text!)!
    animationNumbers.completedEnd = history.completed!.integerValue
    animationNumbers.skippedStart = Int(skipped.text!)!
    animationNumbers.skippedEnd = history.skipped!.integerValue
  }
  
}
