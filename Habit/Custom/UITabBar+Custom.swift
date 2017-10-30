//
//  UITabBar+Custom.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

import UIKit

extension UITabBar {
  
  func isSelected(title: String) -> Bool {
    return selectedItem?.title == title
  }
  
}
