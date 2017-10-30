//
//  UIButton+Color.swift
//  Habit
//
//  Created by harry on 7/6/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

extension UIButton {
  
  func setBackgroundColor(color: UIColor, forState state: UIControlState) {
    let rect = CGRect(x: 0, y:  0, width:  1, height:  1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    setBackgroundImage(image, for: state)
  }  
  
  func roundify(radius: CGFloat) {
    layer.cornerRadius = radius
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.6
    layer.shadowRadius = 5
    layer.shadowOffset = CGSize(width: 0, height: 1)
  }
  
}
