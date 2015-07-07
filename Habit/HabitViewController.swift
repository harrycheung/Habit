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

class HabitViewController : UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var habit: Habit?
  
  @IBOutlet weak var name: UITextField!
  @IBOutlet weak var frequency: UISegmentedControl!
  @IBOutlet weak var cancel: UIButton!
  @IBOutlet weak var done: UIButton!
  @IBOutlet weak var frequencyScroller: UIScrollView!
  @IBOutlet weak var frequencyScrollerContent: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    let recognizer = UITapGestureRecognizer(target: self, action: "dismissModal:")
    recognizer.cancelsTouchesInView = false
    recognizer.numberOfTapsRequired = 1
    frequency.addGestureRecognizer(recognizer)
    view.addGestureRecognizer(recognizer)
    
    if !habit!.isNew() {
      cancel.setTitle("Delete", forState: .Normal)
    } else {
      name.becomeFirstResponder()
    }
    
    enableDone()
    
    let p1 = FrequencySettings(leftTitle: "How many times a day?",
      pickerCount: 12,
      rightTitle: "What parts of the day?",
      multiSelectItems: ["Morning", "Mid-Morning", "Midday", "Mid-Afternoon", "Afternoon", "Evening"])
    p1.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p1)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Top, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Top, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Left, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Left, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p1, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
    let p2 = FrequencySettings(leftTitle: "How many times a week?",
                       pickerCount: 6,
                        rightTitle: "What days of the week?",
                  multiSelectItems: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
    p2.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p2)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .CenterY, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .CenterY, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .CenterX, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .CenterX, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p2, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
    
    let p3 = FrequencySettings(leftTitle: "How many times a month?",
      pickerCount: 3,
      rightTitle: "What parts of the month?",
      multiSelectItems: ["Beginning", "Middle", "End"])
    p3.translatesAutoresizingMaskIntoConstraints = false
    frequencyScrollerContent.addSubview(p3)
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Top, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Top, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Right, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Right, multiplier: 1, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Width, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Width, multiplier: 0.33333, constant: 0))
    frequencyScrollerContent.addConstraint(NSLayoutConstraint(item: p3, attribute: .Height, relatedBy: .Equal, toItem: frequencyScrollerContent, attribute: .Height, multiplier: 1, constant: 0))
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    name.resignFirstResponder()
    return true
  }
  
  func dismissModal(recognizer: UIPanGestureRecognizer) {
    name.resignFirstResponder()
  }
  
  @IBAction func frequencyChanged(sender: AnyObject) {
    enableDone()
    let frame = frequencyScroller.bounds
    frequencyScroller.scrollRectToVisible(CGRectMake(CGFloat(frequency.selectedSegmentIndex) * frame.width, 0, frame.width, frame.height), animated: true)
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

}
