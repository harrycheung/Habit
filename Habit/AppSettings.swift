//
//  AppSettings.swift
//  Habit
//
//  Created by harry on 7/13/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class AppSettings : UIView {
  
  @IBOutlet var colors: [UIButton]!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}