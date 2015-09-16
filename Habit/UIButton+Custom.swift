//
//  UIButton+Color.swift
//  Habit
//
//  Created by harry on 7/6/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
  
  func setBackgroundColor(color: UIColor, forState state: UIControlState) {
    let rect = CGRectMake(0, 0, 1, 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    setBackgroundImage(image, forState: state)
  }  
  
  func roundify(radius: CGFloat) {
    layer.cornerRadius = radius
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.6
    layer.shadowRadius = 5
    layer.shadowOffset = CGSizeMake(0, 1)
  }
  
}
