//
//  EditHabitViewController.swift
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

class EditHabitViewController: UIViewController, UITextFieldDelegate, FrequencySettingsDelegate, UIGestureRecognizerDelegate {
  
  let iPhone4Height: CGFloat = 440
  
  var habit: Habit?
  var frequency: Habit.Frequency = .Daily
  var pickerRecognizer: UITapGestureRecognizer?
  var mvc: MainViewController?
  var warnedFrequency: Bool = false
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var frequencyLabel: UILabel!
  @IBOutlet weak var frequencySettings: FrequencySettings!
  @IBOutlet weak var notify: UISwitch!
  @IBOutlet weak var neverAutoSkip: UISwitch!
  @IBOutlet weak var paused: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var toolbar: UIView!
  @IBOutlet weak var height: NSLayoutConstraint!
  @IBOutlet weak var width: NSLayoutConstraint!
  @IBOutlet weak var contentView: UIVisualEffectView!
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup settings views for each frequency
    switch frequency {
    case .Daily:
      frequencySettings.configure(leftTitle: "Times a day",
        pickerCount: 12,
        rightTitle: "Parts of day",
        multiSelectItems: Habit.partOfDayStrings,
        useTimes: habit != nil && habit!.useTimes,
        delegate: self)
    case .Weekly:
      frequencySettings.configure(leftTitle: "Times a week",
        pickerCount: 6,
        rightTitle: "Days of week",
        multiSelectItems: Habit.dayOfWeekStrings,
        useTimes: habit != nil && habit!.useTimes,
        delegate: self)
    case .Monthly:
      frequencySettings.configure(leftTitle: "Times a month",
        pickerCount: 5,
        rightTitle: "Parts of month",
        multiSelectItems: Habit.partOfMonthStrings,
        useTimes: habit != nil && habit!.useTimes,
        delegate: self)
    default: ()
    }
    
    // Fill out the form
    if habit != nil {
      frequencyLabel.text = "Edit \(frequency.description.lowercaseString) habit"
      name.text = habit!.name;
      if habit!.useTimes {
        frequencySettings!.picker.selectRow(habit!.times!.integerValue - 1, inComponent: 0, animated: false)
      } else {
        frequencySettings!.multiSelect.selectedIndexes = habit!.partsArray.map { $0 - 1 }
      }
      notify.on = habit!.notifyBool
      neverAutoSkip.on = habit!.neverAutoSkipBool
      paused.on = habit!.pausedBool
    } else {
      frequencyLabel.text = "Start a \(frequency.description.lowercaseString) habit"
      frequencySettings!.overlayTouched(frequencySettings!.leftOverlay!, touched: false)
      save.setTitle("Start", forState: .Normal)
      deleteWidth.priority = HabitApp.LayoutPriorityHigh
    }
    save.tintColor = UIColor.whiteColor()
    
    // Tap handlers for closing the keyboard. Note: I need a specific recognizer for
    // the UIPickerViews since they handle the gesture a little differently. I think
    // it's a bug.
    let recognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    pickerRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
    pickerRecognizer!.cancelsTouchesInView = false
    pickerRecognizer!.numberOfTapsRequired = 1
    pickerRecognizer!.delegate = self
    frequencySettings!.picker.addGestureRecognizer(pickerRecognizer!)
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.Close), forState: .Normal)
    
    mvc = presentingViewController!.presentingViewController as? MainViewController
    
    contentView.layer.shadowColor = UIColor.blackColor().CGColor
    contentView.layer.shadowOpacity = 0.6
    contentView.layer.shadowRadius = 5
    contentView.layer.shadowOffset = CGSizeMake(0, 1)
    
    name.attributedPlaceholder = NSAttributedString(string: "describe a habit",
      attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
    name.tintColor = UIColor.whiteColor()
    
    if HabitApp.phoneSize == .iPhone4 {
      height.constant = iPhone4Height
      frequencySettings.picker.transform = CGAffineTransformMakeScale(0.85, 0.85)
    }
  }
  
  override func viewDidLayoutSubviews() {    
    name.tintClearButton()
  }
  
  func frequencySettingsChanged() {
    enableSave()
  }
  
  @IBAction func changed(sender: AnyObject) {
    enableSave()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return pickerRecognizer!.isEqual(gestureRecognizer)
  }
  
  func hideKeyboard(recognizer: UIPanGestureRecognizer) {
    // TODO: or name.resignFirstResponder?
    view.endEditing(true)
  }
  
  @IBAction func closeView(sender: AnyObject) {
    if habit != nil {
      presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    } else {
      let mvc = presentingViewController!.presentingViewController!
      presentingViewController!.dismissViewControllerAnimated(true) {
        mvc.dismissViewControllerAnimated(false, completion: nil)
      }
    }
  }
  
  @IBAction func saveHabit(sender: AnyObject) {
    let save = { (habit: Habit, name: String) in
      let frequencyChanged = self.frequencyChanged()
      // To indicate the habit has been edited
      self.habit = nil
      self.presentingViewController!.view.hidden = true
      self.presentingViewController!.dismissViewControllerAnimated(true) {
        self.mvc!.dismissViewControllerAnimated(false) {
          let pausedSet = habit.paused != self.paused.on
          habit.frequency = self.frequency
          if self.frequencySettings!.useTimes {
            habit.times = self.frequencySettings!.picker!.selectedRowInComponent(0) + 1
            habit.partsArray = []
          } else {
            habit.partsArray = self.frequencySettings!.multiSelect.selectedIndexes.sort().map { $0 + 1 }
          }
          habit.notify = self.notify.on
          habit.neverAutoSkip = self.neverAutoSkip.on
          habit.paused = self.paused.on
          if !habit.isNew {
            if habit.name != name {
              habit.name = name
              self.mvc!.reloadRows(HabitManager.rows(habit))
            }
            if pausedSet {
              if self.paused.on {
                self.mvc!.deleteRows(HabitManager.deleteEntries(after: NSDate(), habit: habit)) {
                  self.mvc!.insertRows(HabitManager.pause(habit))
                }
              } else {
                self.mvc!.deleteRows(HabitManager.unpause(habit)) {
                  self.mvc!.insertRows(HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit))
                }
              }
            } else if frequencyChanged {
              self.mvc!.deleteRows(HabitManager.deleteEntries(after: NSDate(), habit: habit)) {
                self.mvc!.insertRows(HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit))
              }
            }
          } else {
            self.mvc!.insertRows(HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit))
          }
          HabitManager.save()
          // update notifications if name change or frequency changes or new or paused or notify or anything
          HabitManager.updateNotifications()
        }
      }
    }
    
    let trimmedName = name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    if habit == nil {
      if HabitManager.exists(trimmedName) {
        showAlert(nil,
          message: "Another habit with the same name exists.\nContinue with save?",
          yes: ("Yes", .Default, {
            if self.habit == nil {
              self.habit = Habit(context: HabitApp.moContext, name: trimmedName)
              save(self.habit!, trimmedName)
            } else {
              save(self.habit!, trimmedName)
            }
          }),
          no: ("No", .Cancel, { alert in
            alert.dismissViewControllerAnimated(true, completion: nil)
          }))
      } else {
        self.habit = Habit(context: HabitApp.moContext, name: trimmedName)
        save(self.habit!, trimmedName)
      }
    } else {
      save(self.habit!, trimmedName)
    }
  }
  
  @IBAction func deleteHabit(sender: AnyObject) {
    showAlert(nil, message: nil, yes: ("Delete habit", .Destructive, {
      let rows = HabitManager.delete(self.habit!)
      // Need to update badge numbers
      HabitManager.updateNotifications()
      // Hide ShowHabitViewController
      self.presentingViewController!.view.hidden = true
      self.presentingViewController!.dismissViewControllerAnimated(true) {
        self.mvc!.dismissViewControllerAnimated(false) {
          self.mvc!.deleteRows(rows)
        }
      }
      self.habit = nil
    }), no: ("Cancel", .Cancel, { alert in
      alert.dismissViewControllerAnimated(true, completion: nil)
    }))
  }
  
  private func frequencyChanged() -> Bool {
    if habit!.isNew {
      return false
    }
    var valid = true
    var changed = false
    if frequencySettings.useTimes {
      changed = frequencySettings.picker.selectedRowInComponent(0) != habit!.timesInt - 1
    } else {
      valid = valid && !frequencySettings.multiSelect.selectedIndexes.isEmpty
      changed = frequencySettings.multiSelect.selectedIndexes != habit!.partsArray.map { $0 - 1 }
    }
    if valid && changed && !warnedFrequency {
      let alert = UIAlertController(title: "Warning",
        message: "Changes to frequency will\naffect ALL future entries.",
        preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
      warnedFrequency = true
    }
    return valid && changed
  }
  
  private func enableSave() {
    if habit != nil {
      // Old habit
      var changed = name.text! != habit!.name!
      changed = changed || notify.on != habit!.notifyBool
      changed = changed || neverAutoSkip.on != habit!.neverAutoSkipBool
      changed = changed || paused.on != habit!.pausedBool
      changed = frequencyChanged() || changed
      save.enabled = !name.text!.isEmpty && changed
    } else {
      // New habit
      save.enabled = !name.text!.isEmpty
      if !frequencySettings.useTimes {
        save.enabled = save.enabled && !frequencySettings.multiSelect.selectedIndexes.isEmpty
      }
    }
  }
  
  private func showAlert(title: String?, message: String?,
    yes: (title: String, style: UIAlertActionStyle, handler: (() -> Void)),
    no: (title: String, style: UIAlertActionStyle, handler: ((UIAlertController) -> Void))) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
      alert.addAction(UIAlertAction(title: yes.title, style: yes.style) { action in
        yes.handler()
      })
      alert.addAction(UIAlertAction(title: no.title, style: no.style) { action in
        no.handler(alert)
      })
      presentViewController(alert, animated: true, completion: nil)
  }
  
}
