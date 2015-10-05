//
//  HabitTableViewCell.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class HabitTableViewCell: SwipeTableViewCell {
  
  var entry: Entry?
  var bottomBorder: CALayer?
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var due: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    contentView.backgroundColor = HabitApp.color
    
    bottomBorder = CALayer()
    let frame = contentView.frame
    bottomBorder!.frame = CGRectMake(0, 0, frame.width, 1)
    bottomBorder!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
    layer.addSublayer(bottomBorder!)
  }
  
  func load(entry: Entry) {
    self.entry = entry
    reload()
  }

  func reload() {
    // Not sure why this tint needs be set here, but otherwise, it picks up the global tint sometimes.
    name.text = entry!.habit!.name
    due.text = entry!.dueText
    let dueIn = entry!.dueIn
    var alpha = HabitApp.MinimumAlpha
    if dueIn < 10 * 60 {
      alpha = 1.0
    } else if dueIn < 24 * 3600 {
      alpha = HabitApp.MinimumAlpha + (1 - HabitApp.MinimumAlpha) * pow(1000, -CGFloat(dueIn) / (24 * 3600))
    }
    if contentView.backgroundColor != nil {
      contentView.backgroundColor = UIColor(color: HabitApp.color, fadeToAlpha: alpha)
    } else {
      contentView.alpha = alpha
    }
  }
}
