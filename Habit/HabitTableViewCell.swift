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
  let MinimumAlpha:CGFloat = 0.4
  
  var habit: Habit?
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var due: UILabel!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func load(habit: Habit) {
    self.habit = habit;
    reload()
  }

  func reload() {
    name.text = habit!.name
    due.text = habit!.dueText()
    let dueIn = habit!.dueIn()
    var alpha = MinimumAlpha
    if dueIn < 24 * 3600 {
      alpha = min(CGFloat(0.2 + 0.8 * abs(1 - dueIn / (24 * 3600))), 1)
    }
    if contentView.backgroundColor != nil {
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      contentView.backgroundColor!.getRed(&red, green: &green, blue: &blue, alpha: nil)
      contentView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    } else {
      contentView.alpha = alpha
    }
  }
  
}