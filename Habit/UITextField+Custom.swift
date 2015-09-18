//
//  UITextField+Custom.swift
//  Habit
//
//  Created by harry on 9/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UITextField {
  
  func tintClearButton() {
    for view in subviews {
      if view is UIButton {
        let button = view as! UIButton
        if let uiImage = button.imageForState(.Highlighted) {
          let tintImage = { (image: UIImage, color: UIColor) -> UIImage in
            let size = image.size
            
            UIGraphicsBeginImageContextWithOptions(size, false, 2)
            let context = UIGraphicsGetCurrentContext()
            image.drawAtPoint(CGPointZero, blendMode: .Normal, alpha: 1.0)
            
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextSetBlendMode(context, .SourceIn)
            CGContextSetAlpha(context, 1.0)
            
            let rect = CGRectMake(CGPointZero.x, CGPointZero.y, image.size.width, image.size.height)
            CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return tintedImage
          }
          
          let tintedClearImage = tintImage(uiImage, tintColor)
          button.setImage(tintedClearImage, forState: .Normal)
          button.setImage(tintedClearImage, forState: .Highlighted)
        }
      }
    }
  }
}