//
//  AppSettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class AppSettingsViewController: UIViewController, ColorPickerDataSource, ColorPickerDelegate {
  
  var mvc: MainViewController?
  
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var colorPicker: ColorPicker!
  @IBOutlet weak var upcoming: UISwitch!
  @IBOutlet weak var notification: UISwitch!
  @IBOutlet weak var autoskip: UISwitch!
  @IBOutlet weak var defaultAbbreviation: UILabel!
  @IBOutlet weak var defaultTimeZone: UILabel!
  @IBOutlet weak var local: UIView!
  @IBOutlet weak var localLabel: UILabel!
  @IBOutlet weak var localAbbreviation: UILabel!
  @IBOutlet weak var localTimeZone: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    close.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    close.setTitle(String.fontAwesomeIconWithName(.ChevronDown), forState: .Normal)
    
    colorPicker.selectedIndex = HabitApp.colorIndex
    upcoming.on = HabitApp.upcoming
    notification.on = !HabitApp.notification
    autoskip.on = HabitApp.autoskip
    let timeZone = NSTimeZone(name: HabitApp.timeZone)!
    defaultTimeZone.text = timeZone.name.stringByReplacingOccurrencesOfString("_", withString: " ")
    defaultAbbreviation.text = timeZone.abbreviation!
    let localTZ = NSTimeZone.localTimeZone()
    if localTZ != timeZone {
      localAbbreviation.text = localTZ.abbreviation!
      localTimeZone.text = localTZ.name.stringByReplacingOccurrencesOfString("_", withString: " ")
    } else {
      local.removeFromSuperview()
      view.layoutSubviews()
    }
    
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOpacity = 0.5
    view.layer.shadowRadius = 4
    view.layer.shadowOffset = CGSizeMake(0, -1)
    
    mvc = presentingViewController as? MainViewController
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
    mvc!.changeColor(HabitApp.colors[index])
    HabitApp.colorIndex = index
  }
  
  @IBAction func upcomingChanged(sender: AnyObject) {
    HabitApp.upcoming = upcoming.on
    mvc!.reloadEntries()
    mvc!.tableView.reloadData()
  }
  
  @IBAction func notificationChanged(sender: AnyObject) {
    HabitApp.notification = !notification.on
    if HabitApp.notification {
      mvc!.refreshNotifications()
    } else {
      UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
  }
  
  @IBAction func autoskipChanged(sender: AnyObject) {
    HabitApp.autoskip = autoskip.on
  }
  
}
