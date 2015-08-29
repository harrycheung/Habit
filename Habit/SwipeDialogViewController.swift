//
//  SwipeDialogViewController.swift
//  Habit
//
//  Created by harry on 8/27/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class SwipeDialogViewController: UIViewController {
  
  var yesCompletion: (() -> Void)?
  var noCompletion: (() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOpacity = 1
    view.layer.shadowRadius = 10
    view.layer.shadowOffset = CGSizeMake(0, 5)
  }
  
  @IBAction func yes(sender: AnyObject) {
    if let complete = yesCompletion { complete() }
  }
  
  @IBAction func no(sender: AnyObject) {
    if let complete = noCompletion { complete() }
  }
}