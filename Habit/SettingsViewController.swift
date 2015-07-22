//
//  SettingsViewController.swift
//  Habit
//
//  Created by harry on 7/17/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var settingsHeight: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func panning(recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translationInView(view)
    //if (translation.y > 0) {
      view.frame = CGRectMake(0, translation.y, view.frame.width, view.frame.height)
    //}
    if(recognizer.state == .Ended) {
      performSegueWithIdentifier("SettingsUnwind", sender: self)
    }
  }
  
}
