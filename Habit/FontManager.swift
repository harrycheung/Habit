//
//  FontManager.swift
//  Habit
//
//  Created by harry on 9/29/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation

class FontManager {
  
  private var fonts = [CGFloat: UIFont]()
  
  private static var instance: FontManager = {
    return FontManager()
  }()

  static func regular(size: CGFloat) -> UIFont {
    if let font = instance.fonts[size] {
      return font
    } else {
      let font = UIFont(name: "Bariol-Regular", size: size)!
      instance.fonts[size] = font
      return font
    }
  }
  
}
