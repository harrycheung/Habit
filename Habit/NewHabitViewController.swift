//
//  NewHabitViewController.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData
import FontAwesome_swift

class NewHabitViewController: UIViewController {
  
  @IBOutlet weak var blurView: UIView!
  @IBOutlet weak var closeButton: UIButton!
  var dailyButton: UIButton?
  var weeklyButton: UIButton?
  var monthlyButton: UIButton?
  
  func showNewHabit(frequency: Habit.Frequency) {
    let mvc = presentingViewController!
    dismissViewControllerAnimated(true) {
      let hsvc = self.storyboard!.instantiateViewControllerWithIdentifier("HabitSettingsViewController") as! HabitSettingsViewController
      hsvc.frequency = frequency
      mvc.presentViewController(hsvc, animated: true, completion: nil)
    }
  }
  
  func buttonDTapped() { showNewHabit(.Daily) }
  func buttonWTapped() { showNewHabit(.Weekly) }
  func buttonMTapped() { showNewHabit(.Monthly) }
  
}
