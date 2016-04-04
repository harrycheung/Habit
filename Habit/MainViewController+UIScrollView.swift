//
//  MainViewController+UIScrollView.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

extension MainViewController {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    //    NSLog("\(scrollView.contentOffset)")
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    if tabBar.selectedIndex == 0 {
      UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 0
      }
    }
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if tabBar.selectedIndex == 0 {
      if !decelerate {
        UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
          self.newButton.alpha = 1
        }
      }
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if tabBar.selectedIndex == 0 {
      UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    }
  }
  
}
