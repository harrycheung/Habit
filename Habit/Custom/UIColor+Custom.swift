//
//  UIColor+Custom.swift
//  Habit
//
//  Created by harry on 8/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

extension UIColor {
  
  convenience init(color: UIColor, fadeToAlpha alpha: CGFloat) {
    var alpha = alpha
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    alpha = 1 - alpha
    red += (1 - red) * alpha
    green += (1 - green) * alpha
    blue += (1 - blue) * alpha
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }
  
}
