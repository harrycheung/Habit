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

class HabitViewController : UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var habit: Habit?
  var timesValue: Int = 0
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var times: UITextField!
  @IBOutlet weak var cancel: UIButton!
  @IBOutlet weak var due: UILabel!
  
  override func viewDidLoad() {
    NSLog("HabitViewController.viewDidLoad")
    super.viewDidLoad()
    NSLog("HabitViewController.viewDidLoad after super")
    
    view.userInteractionEnabled = true
    
    name.text = habit!.name;
    name.delegate = self
    frequency.selectedSegmentIndex = Int(habit!.frequency!)
    times.text = habit!.times!.stringValue
    timesValue = Int(habit!.times!)
    setTimesText()
    
    let picker = UIPickerView()
    picker.dataSource = self
    picker.delegate = self
    picker.selectRow(Int(habit!.times!) - 1, inComponent: 0, animated: false)
    times.inputView = picker
    
    let recognizer = UITapGestureRecognizer(target: self, action: "dismissModal:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    frequency.addGestureRecognizer(recognizer)
    view.addGestureRecognizer(recognizer)
    
    if !habit!.isNew() {
      cancel.setTitle("Delete", forState: .Normal)
      due.text = "in \(Int(habit!.dueIn())) seconds"
    }
    NSLog("HabitViewController.viewDidLoad end")
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func dismissModal(recognizer: UIPanGestureRecognizer) {
    name.resignFirstResponder()
    times.resignFirstResponder()
  }
  
  @IBAction func frequencyChanged(sender: AnyObject) {
    setTimesText()
  }
  
  func setTimesText() {
    var repeatText = ""
    switch frequency.selectedSegmentIndex {
    case Habit.Frequency.Hourly.hashValue:
      repeatText = "hour"
    case Habit.Frequency.Daily.hashValue:
      repeatText = "day"
    case Habit.Frequency.Weekly.hashValue:
      repeatText = "week"
    case Habit.Frequency.Monthly.hashValue:
      repeatText = "month"
    case Habit.Frequency.Annually.hashValue:
      repeatText = "year"
    default: ()
    }
    
    if timesValue == 1 {
      times.text = "1 time a \(repeatText)"
    } else {
      times.text = "\(timesValue) times a \(repeatText)"
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let button = sender as! UIButton
    if button.titleForState(.Normal) == "Done" {
      habit!.name = name.text!
      habit!.frequency = frequency.selectedSegmentIndex
      habit!.times = timesValue
      if habit!.isNew() {
        habit!.last = NSDate()
        habit!.createdAt = NSDate()
      }
      do {
        try moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      }
    } else if button.titleForState(.Normal) == "Delete" {
      moContext.deleteObject(habit!)
      do {
        try moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      }
      habit = nil
    } else {
      habit = nil
    }
  }
  
  // UIPickerView
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
    
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 10
  }
    
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(row + 1)
  }
    
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    timesValue = row + 1
    setTimesText()
    times.resignFirstResponder()
  }

}
