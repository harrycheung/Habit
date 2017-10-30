//
//  SettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class SettingsViewController: UIViewController {
  
  let PanMinimum: CGFloat = 0.5
  
  var mvc: MainViewController!
  var darkenView: UIView!
  
  @IBOutlet weak var blurView: UIView!
  @IBOutlet weak var settingsView: UIView!
  @IBOutlet weak var slideConstraint: NSLayoutConstraint!
  @IBOutlet weak var close: UIButton!
  @IBOutlet weak var colorPicker: ColorPicker!
  
  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    close.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
    close.setTitle(String.fontAwesomeIcon(name: .chevronDown), for: .normal)
    
    colorPicker.delegate = self
    colorPicker.configure(colors: Constants.colors)
    colorPicker.selectedIndex = HabitApp.colorIndex
    
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.5
    view.layer.shadowRadius = 4
    view.layer.shadowOffset = CGSize(width: 0, height: -1)
    
    mvc = presentingViewController as? MainViewController
    
    slideConstraint.priority = Constants.LayoutPriorityLow
    view.layoutIfNeeded()
  }
  
  @IBAction func panning(recognizer: UIPanGestureRecognizer) {
    let movement = max(recognizer.translation(in: view).y, 0)
    settingsView.frame = CGRect(x: 0, y:  movement + settingsView.frame.origin.y, width: 
                                    settingsView.frame.width, height:  settingsView.frame.height)
    let panPercentage = movement / settingsView.frame.height
    close.alpha = max(1 - panPercentage / PanMinimum, 0)

    if recognizer.state == .ended || recognizer.state == .cancelled {
      if panPercentage < PanMinimum {
        UIView.animate(withDuration: SettingsTransition.TransitionDuration,
          delay: 0,
          usingSpringWithDamping: SettingsTransition.SpringDamping,
          initialSpringVelocity: SettingsTransition.SpringVelocity,
          options: SettingsTransition.AnimationOptions,
          animations: {
            self.settingsView.frame = CGRect(x: 0, y:  0, width:  self.view.frame.width, height:  self.view.frame.height)
            self.close.alpha = 1
          }, completion: nil)
      } else {
        closeSettings(recognizer)
      }
    }
  }
  
  @IBAction func closeSettings(_ sender: Any) {
    self.dismiss(animated: true);
  }
  
}

extension SettingsViewController: ColorPickerDelegate {
  
  func colorPicked(colorPicker: ColorPicker, colorIndex index: Int) {
    mvc.changeColor(color: Constants.colors[index])
    HabitApp.colorIndex = index
  }
  
}
