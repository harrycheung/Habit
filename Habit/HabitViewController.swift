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

class HabitViewController : UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate {
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var habit: Habit?
  var timesValue: Int = 0
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var times: UITextField!
  @IBOutlet weak var timesQuestion: UILabel!
  @IBOutlet weak var cancel: UIButton!
  @IBOutlet weak var due: UILabel!
  @IBOutlet weak var done: UIButton!
  @IBOutlet weak var settings: UIView!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //view.userInteractionEnabled = true
    
    name.text = habit!.name;
    name.delegate = self
    switch Habit.Frequency(rawValue: habit!.frequency!.integerValue)! {
    case .Daily:
      frequency.selectedSegmentIndex = 0
    case .Weekly:
      frequency.selectedSegmentIndex = 1
    case .Monthly:
      frequency.selectedSegmentIndex = 2
    default: ()
    }
//    times.text = habit!.times!.stringValue
    timesValue = Int(habit!.times!)
//    setTimesQuestion()
    
    let picker = UIPickerView()
    picker.dataSource = self
    picker.delegate = self
    picker.selectRow(Int(habit!.times!) - 1, inComponent: 0, animated: false)
//    times.inputView = picker
    
    let recognizer = UITapGestureRecognizer(target: self, action: "dismissModal:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    frequency.addGestureRecognizer(recognizer)
    view.addGestureRecognizer(recognizer)
    
    if !habit!.isNew() {
      cancel.setTitle("Delete", forState: .Normal)
      due.text = "in \(habit!.dueText())"
    } else {
      name.becomeFirstResponder()
    }
    
    enableDone()
    
    let p1 = UIView()
    p1.backgroundColor = UIColor.redColor()
    p1.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p1)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Top, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Top, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Left, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Left, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
    let p2 = UIView()
    p2.backgroundColor = UIColor.greenColor()
    p2.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p2)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .Top, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Top, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .CenterX, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .CenterX, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
    let p3 = UIView()
    p3.backgroundColor = UIColor.blueColor()
    p3.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p3)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Top, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Top, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Right, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Right, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
    
    
//    let weeks = HabitWeekly()
//    weeks.backgroundColor = UIColor.blueColor()
//    weeks.translatesAutoresizingMaskIntoConstraints = false
//    weekly.addSubview(weeks)
//    weekly.addConstraint(NSLayoutConstraint(item: weeks, attribute: .Top, relatedBy: .Equal, toItem: weekly, attribute: .Top, multiplier: 1.0, constant: 0))
//    weekly.addConstraint(NSLayoutConstraint(item: weeks, attribute: .Bottom, relatedBy: .Equal, toItem: weekly, attribute: .Bottom, multiplier: 1.0, constant: 0))
//    weekly.addConstraint(NSLayoutConstraint(item: weeks, attribute: .Left, relatedBy: .Equal, toItem: weekly, attribute: .Left, multiplier: 1.0, constant: 0))
//    weekly.addConstraint(NSLayoutConstraint(item: weeks, attribute: .Right, relatedBy: .Equal, toItem: weekly, attribute: .Right, multiplier: 1.0, constant: 0))
//    
    //view.addSubview(HabitWeekly(frame: weekly.frame))
//    let xib = NSBundle.mainBundle().loadNibNamed("HabitWeekly", owner: self, options: nil).first as! UIView
//    //xib.frame = weekly.frame
//    weekly.addSubview(xib)
//    NSLog("weekly.frame: \(weekly.frame)")
//    xib.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
//    xib.frame = CGRectMake(0, 0, weekly.frame.width, weekly.frame.height)
//    NSLog("xib.bounds: \(xib.bounds)")
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func dismissModal(recognizer: UIPanGestureRecognizer) {
    name.resignFirstResponder()
//    times.resignFirstResponder()
  }
  
  @IBAction func frequencyChanged(sender: AnyObject) {
//    setTimesQuestion()
    enableDone()
    let frame = frequencyScroller.bounds
    frequencyScroller.scrollRectToVisible(CGRectMake(CGFloat(frequency.selectedSegmentIndex) * frame.width, 0, frame.width, frame.height), animated: true)
  }
  
  func setTimesQuestion() {
    var timesText = ""
    switch frequency.selectedSegmentIndex {
    case 0:
      timesText = "day"
    case 1:
      timesText = "week"
    case 2:
      timesText = "month"
    default: ()
    }
    timesQuestion.text = "How many times a \(timesText)?"
  }
  
  @IBAction func nameEntered(sender: AnyObject) {
    enableDone()
  }
  
  func enableDone() {
    if name.text!.isEmpty && frequency.selectedSegmentIndex >= 0 {
      done.enabled = false
    } else {
      done.enabled = true
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
  
  // UIScrollView
  
  
  // UIPickerView
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
    
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 12
  }
    
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(row + 1)
  }
    
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    timesValue = row + 1
  }

}
