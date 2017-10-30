//
//  MainViewController+SwipeTableViewCell.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

import UIKit

extension MainViewController: SwipeTableViewCellDelegate {
  
  func startSwiping(cell: SwipeTableViewCell) {
    UIView.animate(withDuration: Constants.NewButtonFadeAnimationDuration) {
      self.newButton.alpha = 0
    }
  }
  
  func endSwiping(cell: SwipeTableViewCell) {
    if presentedViewController == nil {
      UIView.animate(withDuration: Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    }
  }
  
}
