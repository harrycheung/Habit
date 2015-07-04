//
//  HabitWeekly.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class HabitWeekly : UIView {
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var timesView: UIView!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    NSLog("decoder")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    NSBundle.mainBundle().loadNibNamed("HabitWeekly", owner: self, options: nil)
    bounds = view.bounds
    addSubview(view)
    NSLog("frame: \(timesView.bounds)")
    timesView.addSubview(MultiSegmentedControl(segments: ["1", "2", "3", "4", "5", "6", "7"],
      frame: timesView.bounds,
      font: UIFont(name: "Bariol-Regular", size: 20)!))
  }
  
  override func awakeFromNib() {
    NSLog("awakeFromNib")
    timesView.addSubview(MultiSegmentedControl(segments: ["1", "2", "3", "4", "5", "6", "7"],
      frame: timesView.bounds,
      font: UIFont(name: "Bariol-Regular", size: 20)!))
  }

}