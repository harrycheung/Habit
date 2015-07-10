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

class HabitViewController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate, FrequencySettingsDelegate {
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var habit: Habit?
  var blurImage: UIImage?
  var dailySettings: FrequencySettings?
  var weeklySettings: FrequencySettings?
  var monthlySettings: FrequencySettings?
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var settings: UIView!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var blurImageView: UIImageView!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var saveLeading: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup settings views for each frequency
    dailySettings = FrequencySettings(leftTitle: "Times a day",
      pickerCount: 12,
      rightTitle: "Parts of day",
      multiSelectItems: ["Morning", "Mid-Morning", "Midday", "Mid-Afternoon", "Afternoon", "Evening"],
      delegate: self)
    buildSettings(dailySettings!, centerX: 0.33333)
    weeklySettings = FrequencySettings(leftTitle: "Times a week",
      pickerCount: 6,
      rightTitle: "Days of week",
      multiSelectItems: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      delegate: self)
    buildSettings(weeklySettings!, centerX: 1)
    monthlySettings = FrequencySettings(leftTitle: "Times a month",
      pickerCount: 5,
      rightTitle: "Parts of month",
      multiSelectItems: ["Beginning", "Middle", "End"],
      delegate: self)
    buildSettings(monthlySettings!, centerX: 1.66666)
    
    // Setup blurred background
    blurImageView.image = blurImage!.applyBlurWithRadius(5, tintColor: nil, saturationDeltaFactor: 1)
    
    // Fill out the form
    name.text = habit!.name;
    name.delegate = self
    frequency.selectedSegmentIndex = habit!.frequency!.integerValue - 1
    activeFrequencySettings().picker.selectRow(habit!.times!.integerValue - 1, inComponent: 0, animated: false)
    notification.on = habit!.notifyBool
    
    // Tap handler for closing the keyboard
//    let recognizer = UITapGestureRecognizer(target: self, action: "dismissModal:")
//    recognizer.cancelsTouchesInView = false
//    recognizer.numberOfTapsRequired = 1
//    frequency.addGestureRecognizer(recognizer)
//    view.addGestureRecognizer(recognizer)
//    dailySettings!.picker.addGestureRecognizer(recognizer)
//    weeklySettings!.picker.addGestureRecognizer(recognizer)
//    monthlySettings!.picker.addGestureRecognizer(recognizer)

    // Setup form if this is new
    if habit!.isNew {
      name.becomeFirstResponder()
      save.setTitle("Create", forState: .Normal)
      deleteWidth.constant = 0
      saveLeading.constant = 0
    }
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
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
    view.endEditing(true)
    super.touchesBegan(touches, withEvent: event)
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
  
  func dismissModal(recognizer: UIPanGestureRecognizer) {
    name.resignFirstResponder()
  }
  
  func scrollToSettings(index: Int, animated: Bool = false) {
    let bounds = frequencyScroller.bounds
    frequencyScroller.scrollRectToVisible(
      CGRectMake(CGFloat(index) * bounds.width, 0, bounds.width, bounds.height), animated: animated)
  }
  
  func enableSave() {
    let settings = activeFrequencySettings()
    if !habit!.isNew && name.text! == habit!.name! && notification.on == habit!.notifyBool &&
       frequency.selectedSegmentIndex == habit!.frequency!.integerValue - 1 {
      // If name and frequency is the same, test frequency settings
      save.enabled = (settings.leftOverlay!.active &&
                       (!habit!.useTimes || settings.picker.selectedRowInComponent(0) != habit!.timesInt - 1)) ||
                     (settings.rightOverlay!.active && !settings.multiSelect.selectedIndexes.isEmpty &&
                       (habit!.useTimes || settings.multiSelect.selectedIndexes != habit!.partsArray))
    } else {
      // If either name or frequency is different, check frequency settings too
      save.enabled = !name.text!.isEmpty
      if settings.rightOverlay!.active {
        save.enabled = save.enabled && !settings.multiSelect.selectedIndexes.isEmpty
      }
    }
  }
  
  func activeFrequencySettings() -> FrequencySettings {
    switch frequency.selectedSegmentIndex {
    case 1:
      return weeklySettings!
    case 2:
      return monthlySettings!
    default:
      return dailySettings!
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let button = sender as! UIButton
    if button.isEqual(save) {
      habit!.name = name.text!
      habit!.frequency = frequency.selectedSegmentIndex + 1
      habit!.times = activeFrequencySettings().picker!.selectedRowInComponent(0) + 1
      habit!.notifyBool = notification.on
      if habit!.isNew {
        habit!.last = NSDate()
        habit!.createdAt = NSDate()
      }
      do {
        try moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      }
    } else {
      if button.titleForState(.Normal) == "Delete" {
        moContext.deleteObject(habit!)
        do {
          try moContext.save()
        } catch let error as NSError {
          NSLog("Could not save \(error), \(error.userInfo)")
        }
      } else if button.titleForState(.Normal) == "X" {
        if habit!.isNew {
          moContext.deleteObject(habit!)
        } else {
          return
        }
      }
      habit = nil
    }
  }

}
