//
//  EditHabitViewController.swift
//  Habit
//
//  Created by harry on 8/14/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import KAProgressLabel
import FontAwesome_swift

class EditHabitViewController: UIViewController {
  
  let iPhone4Height: CGFloat = 440
  
  var habit: Habit?
  var frequency: Habit.Frequency = .Daily
  var mvc: MainViewController!
  var warnedFrequency: Bool = false
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var frequencyLabel: UILabel!
  @IBOutlet weak var frequencySettings: FrequencySettings!
  @IBOutlet weak var notify: UISwitch!
  @IBOutlet weak var notifySetting: UISegmentedControl!
  @IBOutlet weak var neverAutoSkip: UISwitch!
  @IBOutlet weak var paused: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var height: NSLayoutConstraint!
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup settings views for each frequency
    switch frequency {
    case .Daily:
      frequencySettings.configure(leftTitle: "Times a day",
                                  times: 8,
                                  timesColumns: 4,
                                  rightTitle: "Parts of day",
                                  partsItems: Habit.partOfDayStrings,
                                  partsColumns: 1,
                                  useTimes: habit != nil && habit!.useTimes,
                                  delegate: self)
      notifySetting.setTitle("Morning due", forSegmentAtIndex: 0)
      notifySetting.setTitle("An hour before", forSegmentAtIndex: 1)
    case .Weekly:
      frequencySettings.configure(leftTitle: "Times a week",
                                  times: 4,
                                  timesColumns: 2,
                                  rightTitle: "Days of week",
                                  partsItems: Habit.dayOfWeekStrings,
                                  partsColumns: 2,
                                  useTimes: habit != nil && habit!.useTimes,
                                  delegate: self)
      notifySetting.setTitle("Week before", forSegmentAtIndex: 0)
      notifySetting.setTitle("Day before", forSegmentAtIndex: 1)
    case .Monthly:
      frequencySettings.configure(leftTitle: "Times a month",
                                  times: 4,
                                  timesColumns: 2,
                                  rightTitle: "Parts of month",
                                  partsItems: Habit.partOfMonthStrings,
                                  partsColumns: 1,
                                  useTimes: habit != nil && habit!.useTimes,
                                  delegate: self)
      notifySetting.setTitle("2 weeks before", forSegmentAtIndex: 0)
      notifySetting.setTitle("Week before", forSegmentAtIndex: 1)
    default: ()
    }
    
    // Fill out the form
    if habit != nil {
      frequencyLabel.text = "Edit \(frequency.description.lowercaseString) habit"
      name.text = habit!.name;
      if habit!.useTimes {
        frequencySettings.timesMultiSelect.selectedIndexes = [habit!.times!.integerValue - 1]
      } else {
        frequencySettings.partsMultiSelect.selectedIndexes = habit!.partsArray.map { $0 - 1 }
      }
      notify.on = habit!.notifyBool
      neverAutoSkip.on = habit!.neverAutoSkipBool
      paused.on = habit!.pausedBool
    } else {
      frequencyLabel.text = "Start a \(frequency.description.lowercaseString) habit"
      frequencySettings.overlayTouched(frequencySettings.leftOverlay!, touched: false)
      save.setTitle("Start", forState: .Normal)
      deleteWidth.priority = Constants.LayoutPriorityHigh
    }
    save.tintColor = UIColor.whiteColor()
    
    // Tap handlers for closing the keyboard. Note: I need a specific recognizer for
    // the UIPickerViews since they handle the gesture a little differently. I think
    // it's a bug.
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(EditHabitViewController.hideKeyboard(_:)))
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
//    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.Close), forState: .Normal)
    
    mvc = presentingViewController!.presentingViewController as? MainViewController
    
    name.attributedPlaceholder = NSAttributedString(string: "describe a habit",
      attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
    name.tintColor = UIColor.whiteColor()
    
    notifySetting.setTitleTextAttributes([NSForegroundColorAttributeName: HabitApp.color], forState: .Selected)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    name.tintClearButton()
  }
  
  @IBAction func changed(sender: AnyObject) {
    enableSave()
  }
  
  func hideKeyboard(recognizer: UIPanGestureRecognizer) {
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
        self.mvc.dismissViewControllerAnimated(false) {
          let pausedSet = habit.paused != self.paused.on
          habit.frequency = self.frequency
          if self.frequencySettings.useTimes {
            habit.times = self.frequencySettings.timesMultiSelect.selectedIndexes[0] + 1
            habit.partsArray = []
          } else {
            habit.partsArray = self.frequencySettings.partsMultiSelect.selectedIndexes.sort().map { $0 + 1 }
          }
          habit.notify = self.notify.on
          habit.neverAutoSkip = self.neverAutoSkip.on
          habit.paused = self.paused.on
          if habit.isNew {
            HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit)
            // Minus 1 because createEntries increments
            self.mvc.insertRows([NSIndexPath(forRow: HabitManager.habitCount - 1, inSection: 0)])
          } else {
            if habit.name != name {
              habit.name = name
              self.mvc.reloadRows(HabitManager.rows(habit))
            }
            if pausedSet {
              if self.paused.on {
                self.mvc.deleteRows(HabitManager.deleteEntries(after: NSDate(), habit: habit)) {
                  //self.mvc.insertRows(HabitManager.pause(habit))
                }
              } else {
//                self.mvc.deleteRows(HabitManager.unpause(habit)) {
//                  //self.mvc.insertRows(HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit))
//                }
              }
            } else if frequencyChanged {
              self.mvc.deleteRows(HabitManager.deleteEntries(after: NSDate(), habit: habit)) {
                self.mvc.insertRows(HabitManager.createEntries(after: NSDate(), currentDate: NSDate(), habit: habit))
              }
            }
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
        self.mvc.dismissViewControllerAnimated(false) {
          self.mvc.deleteRows(rows)
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
      changed = frequencySettings.timesMultiSelect.selectedIndexes[0] != habit!.timesInt - 1
    } else {
      valid = valid && !frequencySettings.partsMultiSelect.selectedIndexes.isEmpty
      changed = frequencySettings.partsMultiSelect.selectedIndexes != habit!.partsArray.map { $0 - 1 }
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
      if frequencySettings.useTimes {
        save.enabled = save.enabled && !frequencySettings.timesMultiSelect.selectedIndexes.isEmpty
      } else {
        save.enabled = save.enabled && !frequencySettings.partsMultiSelect.selectedIndexes.isEmpty
      }
    }
  }
  
  private func showAlert(title: String?,
                         message: String?,
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

extension EditHabitViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
}

extension EditHabitViewController: FrequencySettingsDelegate {
  
  func frequencySettingsChanged() {
    enableSave()
  }
  
}
