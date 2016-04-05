//
//  MainViewController+SwipeTableViewCell.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

extension MainViewController: SwipeTableViewCellDelegate {
  
  func startSwiping(cell: SwipeTableViewCell) {
    if tabBar.isSelected(Constants.TabAll) {
      UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 0
      }
    }
  }
  
  func endSwiping(cell: SwipeTableViewCell) {
    if tabBar.isSelected(Constants.TabAll) {
      if presentedViewController == nil {
        UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
          self.newButton.alpha = 1
        }
      }
    }
  }
  
}
