//
//  UITextField+Custom.swift
//  Habit
//
//  Created by harry on 9/18/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreGraphics

extension UITextField {
  
  func tintClearButton() {
    for view in subviews {
      if view is UIButton {
        let button = view as! UIButton
        if let uiImage = button.image(for: .highlighted) {
          let tintImage = { (image: UIImage, color: UIColor) -> UIImage in
            let size = image.size
            
            UIGraphicsBeginImageContextWithOptions(size, false, 2)
            let context = UIGraphicsGetCurrentContext()
            image.draw(at: .zero, blendMode: .normal, alpha: 1.0)
            
            context?.setFillColor(color.cgColor)
            context?.setBlendMode(.sourceIn)
            context?.setAlpha(1.0)
            
            let rect = CGRect(x: CGPoint.zero.x, y:  CGPoint.zero.y, width:  image.size.width, height:  image.size.height)
            UIGraphicsGetCurrentContext()?.fill(rect)
            let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return tintedImage!
          }
          
          let tintedClearImage = tintImage(uiImage, tintColor)
          button.setImage(tintedClearImage, for: .normal)
          button.setImage(tintedClearImage, for: .highlighted)
        }
      }
    }
  }
  
}
