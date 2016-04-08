//
//  SwipeDialogViewController.swift
//  Habit
//
//  Created by harry on 8/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

class SwipeDialogViewController: UIViewController {
  
  @IBOutlet weak var backgroundView: UIView!
  
  var yesCompletion: (() -> Void)?
  var noCompletion: (() -> Void)?
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundView.layer.cornerRadius = 4
  }
  
  @IBAction func yes(sender: AnyObject) {
    yesCompletion?()
  }
  
  @IBAction func no(sender: AnyObject) {
    noCompletion?()
  }
  
}
