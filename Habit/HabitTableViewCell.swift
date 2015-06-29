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
  @IBOutlet weak var entries: UILabel!
  
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
    if dueIn < 10 * 60 {
      alpha = 1.0
    } else if dueIn < 24 * 3600 {
      alpha = MinimumAlpha + (1 - MinimumAlpha) * (1 - CGFloat(dueIn) / (24 * 3600))
    }
    print("\(name.text): \(habit!.dueIn()): \(alpha)")
    if contentView.backgroundColor != nil {
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      contentView.backgroundColor!.getRed(&red, green: &green, blue: &blue, alpha: nil)
      contentView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    } else {
      contentView.alpha = alpha
    }
    entries.text = String(habit!.entries!.count)
  }
  
}