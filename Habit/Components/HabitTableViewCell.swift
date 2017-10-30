//
//  HabitTableViewCell.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit

class HabitTableViewCell: SwipeTableViewCell {
  
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
      bottomBorder.frame = CGRect(x: 0, y:  0, width:  frame.width, height:  1)
      bottomBorder.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
      layer.addSublayer(bottomBorder!)
    }
  }
  
//  func load(history: History) {
//    self.habit = nil
//    self.history = history
//    if entry.habit!.isFake {
//      name.text = HabitManager.FakeEntries[Int(entry.number)]
//      due.text = ""
//      let alpha = CGFloat(entry.number) / CGFloat(HabitManager.FakeEntries.count - 1)
//      setBackgroundAlpha(alpha: 1 - (1 - Constants.MinimumAlpha) * alpha)
//    } else {
//      name.text = entry.habit!.name
//      due.text = entry.dueText
//      let dueIn = entry.dueIn
//      var alpha = Constants.MinimumAlpha
//      if dueIn < 10 * 60 {
//        alpha = 1.0
//      } else if dueIn < 24 * 3600 {
//        alpha = Constants.MinimumAlpha + (1 - Constants.MinimumAlpha) * pow(1000, -CGFloat(dueIn) / (24 * 3600))
//      }
//      setBackgroundAlpha(alpha: alpha)
//    }
//  }
  
  func load(habit: Habit) {
    self.habit = habit
    if habit.isFake {
      name.text = "Example habit"
    } else {
      name.text = habit.name
    }
    name.font = FontManager.regular(size: 18)
    due.text = ""
    setBackgroundAlpha(alpha: Constants.MinimumAlpha)
  }
  
  func setBackgroundAlpha(alpha: CGFloat) {
    if contentView.backgroundColor != nil {
      contentView.backgroundColor = UIColor(color: HabitApp.color, fadeToAlpha: alpha)
    } else {
      contentView.alpha = alpha
    }
  }
  
}
