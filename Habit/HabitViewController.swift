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
import CocoaLumberjack

class HabitViewController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var habit: Habit?
  var dailySettings: FrequencySettings?
  var weeklySettings: FrequencySettings?
  var monthlySettings: FrequencySettings?
//  var settingsConstraint: Constraint?
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var settings: UIView!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    name.text = habit!.name;
    name.delegate = self
    switch Habit.Frequency(rawValue: habit!.frequency!.integerValue)! {
    case .Weekly:
      frequency.selectedSegmentIndex = 1
    case .Monthly:
      frequency.selectedSegmentIndex = 2
    default:
      frequency.selectedSegmentIndex = 0
    }
    scrollToSettings()
    
    let recognizer = UITapGestureRecognizer(target: self, action: "dismissModal:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    frequency.addGestureRecognizer(recognizer)
    view.addGestureRecognizer(recognizer)

    if habit!.isNew() {
      name.becomeFirstResponder()
      //showSettings(animated: false)
    } else {
      //hideSettings(animated: false)
    }
    
    enableDone()
    
    let dailySettings = FrequencySettings(leftTitle: "How many times a day?",
      pickerCount: 12,
      rightTitle: "What parts of the day?",
      multiSelectItems: ["Morning", "Mid-Morning", "Midday", "Mid-Afternoon", "Afternoon", "Evening"])
    buildSettings(dailySettings, centerX: 0.33333)
    
    let weeklySettings = FrequencySettings(leftTitle: "How many times a week?",
      pickerCount: 6,
      rightTitle: "What days of the week?",
      multiSelectItems: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
    buildSettings(weeklySettings, centerX: 1)
    
    let monthlySettings = FrequencySettings(leftTitle: "How many times a month?",
      pickerCount: 5,
      rightTitle: "What parts of the month?",
      multiSelectItems: ["Beginning", "Middle", "End"])
    buildSettings(monthlySettings, centerX: 1.66666)
  }
  
  func buildSettings(settings: FrequencySettings, centerX: CGFloat) {
    settings.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(settings)
    settings.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(frequencyScrollerContent).multipliedBy(centerX)
      make.centerY.equalTo(frequencyScrollerContent)
      make.width.equalTo(frequencyScrollerContent).multipliedBy(0.33333)
      make.height.equalTo(frequencyScrollerContent)
    }
  }
  
//  func showSettings(animated animated: Bool) {
//    settingsConstraint?.uninstall()
//    settings.snp_makeConstraints { (make) -> Void in
//      settingsConstraint = make.bottom.equalTo(view).constraint
//    }
//    settings.layoutIfNeeded()
//  }
//  
//  func hideSettings(animated animated: Bool) {
//    settingsConstraint?.uninstall()
//    settings.snp_makeConstraints { (make) -> Void in
//      settingsConstraint = make.height.equalTo(100).constraint
//    }
//    settings.layoutIfNeeded()
//  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func dismissModal(recognizer: UIPanGestureRecognizer) {
    name.resignFirstResponder()
  }
  
  @IBAction func frequencyChanged(sender: AnyObject) {
    enableDone()
    scrollToSettings(true)
  }
  
  func scrollToSettings(animated: Bool = false) {
    let frame = frequencyScroller.bounds
    frequencyScroller.scrollRectToVisible(CGRectMake(CGFloat(frequency.selectedSegmentIndex) * frame.width, 0, frame.width, frame.height), animated: true)
  }
  
  @IBAction func nameEntered(sender: AnyObject) {
    enableDone()
  }
  
  func enableDone() {
    if name.text!.isEmpty && frequency.selectedSegmentIndex >= 0 {
      //done.enabled = false
    } else {
      //done.enabled = true
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if sender is UIBarButtonItem {
      habit = nil
      return
    }
    let button = sender as! UIButton
    if button.titleForState(.Normal) == "Done" {
      habit!.name = name.text!
      habit!.frequency = frequency.selectedSegmentIndex
      if habit!.isNew() {
        habit!.last = NSDate()
        habit!.createdAt = NSDate()
      }
      do {
        try moContext.save()
      } catch let error as NSError {
        DDLogError("Could not save \(error), \(error.userInfo)")
      }
    } else if button.titleForState(.Normal) == "Delete" {
      moContext.deleteObject(habit!)
      do {
        try moContext.save()
      } catch let error as NSError {
        DDLogError("Could not save \(error), \(error.userInfo)")
      }
      habit = nil
    } else {
      habit = nil
    }
  }

}
