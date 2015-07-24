//
//  SettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, ColorPickerDataSource, ColorPickerDelegate {
  
  var mainVC: MainViewController?
  
  @IBOutlet weak var settingsHeight: NSLayoutConstraint!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var colorPicker: ColorPicker!
  @IBOutlet weak var upcoming: UISwitch!
  @IBOutlet weak var notification: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.ChevronDown), forState: .Normal)
    
    colorPicker.selectedIndex = HabitApp.colorIndex
    upcoming.on = HabitApp.upcoming
    notification.on = HabitApp.notification
  }
  
  @IBAction func panning(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(view)
    if (translation.y > 0) {
      view.frame = CGRectMake(0, translation.y, view.frame.width, view.frame.height)
    }
    if(recognizer.state == .Ended) {
      performSegueWithIdentifier("SettingsUnwind", sender: self)
    }
  }
  
  func colorPicker(colorPicker: ColorPicker, colorAtIndex index: Int) -> UIColor {
    return HabitApp.colors[index]
  }
  
  func colorPicked(colorPicker: ColorPicker, colorIndex index: Int) {
    mainVC!.changeColor(HabitApp.colors[index])
    HabitApp.colorIndex = index
  }
  
  @IBAction func upcomingChanged(sender: AnyObject) {
    HabitApp.upcoming = upcoming.on
  }
  
  @IBAction func notificationChanged(sender: AnyObject) {
    HabitApp.notification = notification.on
  }
  
}
