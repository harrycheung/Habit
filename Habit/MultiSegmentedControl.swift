//
//  MultiSegmentedControl.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

class MultiSegmentedControl : UIView {
  
  var segments: [String] = []
  var count: Int = 0
  var buttons: [UIButton] = []
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(segments: [String], frame: CGRect, font: UIFont) {
    super.init(frame: frame)
    
    self.segments = segments
    count = segments.count
    let width = frame.width / CGFloat(count)
    for index in 0..<count {
      let buttonFrame = CGRectMake(CGFloat(index) * width, 0,  width, frame.height)
      NSLog("width: \(CGRectIntegral(buttonFrame))")
      let button = UIButton(frame: CGRectIntegral(buttonFrame))
      button.setTitle(segments[index], forState: .Normal)
      button.titleLabel!.font = font
      button.setTitleColor(MainViewController.blue, forState: .Normal)
      addSubview(button)
      buttons.append(button)
    }
  }

}
