//
//  HabitTableViewCell.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit

class HabitTableViewCell: SwipeTableViewCell {
  
  var entry: Entry?
  var habit: Habit?
  var bottomBorder: CALayer!
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var due: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    contentView.backgroundColor = HabitApp.color
  }
  
  override func layoutSubviews() {
    if bottomBorder == nil {
      let frame = contentView.frame
      bottomBorder = CALayer()
      bottomBorder.frame = CGRectMake(0, 0, frame.width, 1)
      bottomBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).CGColor
      layer.addSublayer(bottomBorder!)
    }
  }
  
  func load(entry entry: Entry) {
    self.habit = nil
    self.entry = entry
    if entry.habit!.isFake {
      name.text = HabitManager.FakeEntries[entry.number!.integerValue]
      due.text = ""
      let alpha = CGFloat(entry.number!.floatValue) / CGFloat(HabitManager.FakeEntries.count - 1)
      setBackgroundAlpha(1 - (1 - Constants.MinimumAlpha) * alpha)
    } else {
      name.text = entry.habit!.name
      due.text = entry.dueText
      let dueIn = entry.dueIn
      var alpha = Constants.MinimumAlpha
      if dueIn < 10 * 60 {
        alpha = 1.0
      } else if dueIn < 24 * 3600 {
        alpha = Constants.MinimumAlpha + (1 - Constants.MinimumAlpha) * pow(1000, -CGFloat(dueIn) / (24 * 3600))
      }
      setBackgroundAlpha(alpha)
    }
  }
  
  func load(habit habit: Habit) {
    self.entry = nil
    self.habit = habit
    if habit.isFake {
      name.text = "Example habit"
    } else {
      name.text = habit.name
    }
    due.text = ""
    setBackgroundAlpha(Constants.MinimumAlpha)
  }
  
  func setBackgroundAlpha(alpha: CGFloat) {
    if contentView.backgroundColor != nil {
      contentView.backgroundColor = UIColor(color: HabitApp.color, fadeToAlpha: alpha)
    } else {
      contentView.alpha = alpha
    }
  }
  
}
