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
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    contentView.backgroundColor = tintColor
    
    bottomBorder = CALayer()
    let frame = contentView.frame
    bottomBorder!.frame = CGRectMake(0, 0, frame.width, 1)
    bottomBorder!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
    layer.addSublayer(bottomBorder!)
  }
  
  func load(habit: Habit) {
    self.habit = habit;
    reload()
  }

  func reload() {
    // Not sure why this tint needs be set here, but otherwise, it picks up the global tint sometimes.
    name.tintColor = UIColor.whiteColor()
    name.text = habit!.name
    due.text = habit!.dueText
    let dueIn = habit!.dueIn
    var alpha = MinimumAlpha
    if dueIn < 10 * 60 {
      alpha = 1.0
    } else if dueIn < 24 * 3600 {
      alpha = MinimumAlpha + (1 - MinimumAlpha) * pow(1000, -CGFloat(dueIn) / (24 * 3600))
    }
    if contentView.backgroundColor != nil {
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
      alpha = 1 - alpha
      red += (1 - red) * alpha
      green += (1 - green) * alpha
      blue += (1 - blue) * alpha
      contentView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    } else {
      contentView.alpha = alpha
    }
    entries.text = String(habit!.entries!.count)
  }
}