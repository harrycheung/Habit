//
//  HabitTableViewCell.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class HabitTableViewCell : SwipeTableViewCell {
  var habit: Habit?
  
  @IBOutlet weak var name: UILabel!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func load(habit: Habit) {
    self.habit = habit;
    reload()
  }

  func reload() {
    name.text = habit!.name
  }
}