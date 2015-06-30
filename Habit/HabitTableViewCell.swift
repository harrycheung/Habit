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
  var bottomBorder: CALayer?
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var due: UILabel!
  @IBOutlet weak var entries: UILabel!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    bottomBorder = CALayer()
    let frame = contentView.frame
    bottomBorder!.frame = CGRectMake(0, frame.height, frame.width, 1)
    layer.addSublayer(bottomBorder!)
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
      alpha = MinimumAlpha + (1 - MinimumAlpha) * pow(1000, -CGFloat(dueIn) / (24 * 3600))
    }
    if contentView.backgroundColor != nil {
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      contentView.backgroundColor!.getRed(&red, green: &green, blue: &blue, alpha: nil)
      contentView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
      bottomBorder!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
    } else {
      contentView.alpha = alpha
    }
    entries.text = String(habit!.entries!.count)
  }
}