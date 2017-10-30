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
  
  var habit: Habit?
  var frequency: Habit.Frequency = .Daily
  var mvc: MainViewController!
  var warnedFrequency: Bool = false
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var frequencyLabel: UILabel!
  @IBOutlet weak var frequencySettings: MultiSelectControl!
  @IBOutlet weak var notify: UISwitch!
  @IBOutlet weak var neverAutoSkip: UISwitch!
  @IBOutlet weak var paused: UISwitch!
  @IBOutlet weak var save: UIButton!
  @IBOutlet weak var deleteWidth: NSLayoutConstraint!
  @IBOutlet weak var height: NSLayoutConstraint!
  
  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var times = 0
    var columns = 0
    switch frequency {
    case .Daily:
      times = 12
      columns = 4
    case .Weekly:
      times = 6
      columns = 3
    case .Monthly:
      times = 4
      columns = 2
    default: ()
    }
    frequencySettings.configure(items: [Int](1...times).map { String($0) }, numberofColumns: columns, single: true)
    frequencySettings.font = FontManager.regular(size: 17)
    frequencySettings.tintColor = HabitApp.color
    frequencySettings.delegate = self
    
    // Fill out the form
    if habit != nil {
      frequencyLabel.text = "Edit \(frequency.description.lowercased()) habit"
      name.text = habit!.name;
//      notify.isOn = habit!.notify
//      neverAutoSkip.isOn = habit!.neverAutoSkip
//      paused.isOn = habit!.paused
    } else {
      frequencyLabel.text = "Start a \(frequency.description.lowercased()) habit"
      save.setTitle("Start", for: .normal)
      deleteWidth.priority = Constants.LayoutPriorityHigh
    }
    save.tintColor = UIColor.white
    
    // Tap handlers for closing the keyboard. Note: I need a specific recognizer for
    // the UIPickerViews since they handle the gesture a little differently. I think
    // it's a bug.
    let recognizer =
      UITapGestureRecognizer(target: self,
                             action: #selector(EditHabitViewController.hideKeyboard))
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
//    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    
    close.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
    close.setTitle(String.fontAwesomeIcon(name: .close), for: .normal)
    
    mvc = presentingViewController!.presentingViewController as? MainViewController
    
    name.attributedPlaceholder = NSAttributedString(string: "describe a habit",
                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    name.tintColor = UIColor.white
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    name.tintClearButton()
  }
  
  @IBAction func changed(sender: AnyObject) {
    enableSave()
  }
  
  @objc func hideKeyboard(recognizer: UIPanGestureRecognizer) {
    view.endEditing(true)
  }
  
  @IBAction func closeView(sender: AnyObject) {
    if habit != nil {
      presentingViewController!.dismiss(animated: true, completion: nil)
    } else {
      let mvc = presentingViewController!.presentingViewController!
      presentingViewController!.dismiss(animated: true) {
        mvc.dismiss(animated: false, completion: nil)
      }
    }
  }
  
  @IBAction func saveHabit(sender: AnyObject) {
    let save = { (habit: Habit, name: String) in
      let frequencyChanged = self.frequencyChanged()
      // To indicate the habit has been edited
      self.habit = nil
      self.presentingViewController!.view.isHidden = true
      self.presentingViewController!.dismiss(animated: true) {
        self.mvc.dismiss(animated: false) {
          let pausedSet = habit.paused != self.paused.isOn
          habit.frequency = self.frequency
          habit.partsArray = self.frequencySettings.selectedIndexes.sorted().map { $0 + 1 }
          habit.notify = self.notify.isOn
          habit.paused = self.paused.isOn
          if habit.isNew {
//            _ = HabitManager.createEntries(after: Date(), currentDate: Date(), habit: habit)
            // Minus 1 because createEntries increments
            self.mvc.insertRows(rows: [IndexPath(row: HabitManager.habitCount - 1, section: 0)])
          } else {
            if habit.name != name {
              habit.name = name
              self.mvc.reloadRows(rows: HabitManager.rows(habit: habit))
            }
            if pausedSet {
              if self.paused.isOn {
//                self.mvc.deleteRows(rows: HabitManager.deleteEntries(after: Date(), habit: habit)) {
//                  //self.mvc.insertRows(HabitManager.pause(habit))
//                }
              } else {
//                self.mvc.deleteRows(HabitManager.unpause(habit)) {
//                  //self.mvc.insertRows(HabitManager.createEntries(after: Date(), currentDate: Date(), habit: habit))
//                }
              }
            } else if frequencyChanged {
//              self.mvc.deleteRows(rows: HabitManager.deleteEntries(after: Date(), habit: habit)) {
//                self.mvc.insertRows(rows: HabitManager.createEntries(after: Date(), currentDate: Date(), habit: habit))
//              }
            }
          }
          HabitManager.save()
          // update notifications if name change or frequency changes or new or paused or notify or anything
          HabitManager.updateNotifications()
        }
      }
    }
    
    let trimmedName = name.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
    if habit == nil {
      if HabitManager.exists(name: trimmedName) {
        showAlert(title: nil,
                  message: "Another habit with the same name exists.\nContinue with save?",
                  yes: ("Yes", .default, {
                    if self.habit == nil {
                      self.habit = Habit(context: HabitApp.moContext, name: trimmedName)
                      save(self.habit!, trimmedName)
                    } else {
                      save(self.habit!, trimmedName)
                    }
                  }),
                  no: ("No", .cancel, { alert in
                    alert.dismiss(animated: true, completion: nil)
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
//    showAlert(title: nil, message: nil, yes: ("Delete habit", .destructive, {
//      let rows = HabitManager.delete(habit: self.habit!)
//      // Need to update badge numbers
//      HabitManager.updateNotifications()
//      // Hide ShowHabitViewController
//      self.presentingViewController!.view.isHidden = true
//      self.presentingViewController!.dismiss(animated: true) {
//        self.mvc.dismiss(animated: false) {
//          self.mvc.deleteRows(rows: rows)
//        }
//      }
//      self.habit = nil
//    }), no: ("Cancel", .cancel, { alert in
//      alert.dismiss(animated: true, completion: nil)
//    }))
  }
  
  private func frequencyChanged() -> Bool {
    if habit!.isNew {
      return false
    }
    let valid = !frequencySettings.selectedIndexes.isEmpty
    let changed = frequencySettings.selectedIndexes != habit!.partsArray.map { $0 - 1 }
    if valid && changed && !warnedFrequency {
      let alert = UIAlertController(title: "Warning",
                                    message: "Changes to frequency will\naffect ALL future entries.",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
      present(alert, animated: true, completion: nil)
      warnedFrequency = true
    }
    return valid && changed
  }
  
  private func enableSave() {
    if habit != nil {
      // Old habit
      var changed = name.text! != habit!.name!
      changed = changed || notify.isOn != habit!.notify
      changed = changed || paused.isOn != habit!.paused
      changed = frequencyChanged() || changed
      save.isEnabled = !name.text!.isEmpty && changed
    } else {
      // New habit
      save.isEnabled = !name.text!.isEmpty
      save.isEnabled = save.isEnabled && !frequencySettings.selectedIndexes.isEmpty
    }
  }
  
  private func showAlert(title: String?,
                         message: String?,
                         yes: (title: String, style: UIAlertActionStyle, handler: (() -> Void)),
                         no: (title: String, style: UIAlertActionStyle, handler: ((UIAlertController) -> Void))) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction(title: yes.title, style: yes.style) { action in
        yes.handler()
      })
      alert.addAction(UIAlertAction(title: no.title, style: no.style) { action in
        no.handler(alert)
      })
    present(alert, animated: true, completion: nil)
  }
  
}

extension EditHabitViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
}

extension EditHabitViewController: MultiSelectControlDelegate {
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, indexSelected: Int) {
    enableSave()
  }
  
}
