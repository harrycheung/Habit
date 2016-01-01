//
//  ExpandTabBar.swift
//  Habit
//
//  Created by harry on 12/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

@objc(ExpandTabBarDataSource)
protocol ExpandTabBarDataSource {
  
  func fontOfExpandTabBar(expandTabBar: ExpandTabBar) -> UIFont
  func numberOfTabsInExpandTabBar(ExpandTabBar: ExpandTabBar) -> Int
  func expandTabBar(expandTabBar: ExpandTabBar, itemAtIndex: Int) -> String?
  func defaultIndex(expandTabBar: ExpandTabBar) -> Int
  
}

@objc(ExpandTabBarDelegate)
protocol ExpandTabBarDelegate {
  
  func expandTabBar(expandTabBar: ExpandTabBar, didSelect: Int)
  
}

class ExpandTabBar: UIView {
  
  @IBOutlet var dataSource: ExpandTabBarDataSource?
  @IBOutlet var delegate: ExpandTabBarDelegate?
  
  var buttons: [UILabel] = []
  var count: Int = 0
  var selectedIndex: Int = 0
  
  override func layoutSubviews() {
    // TODO: Is this the right place for adding buttons? The buttons.isEmpty check is necessary.
    // Otherwise, a recursive loop occurs with each button that gets added. The other wasy to "fix"
    // this is to give the superview a height constraint with priority 1000.
    if dataSource != nil && buttons.isEmpty {
      selectedIndex = dataSource!.defaultIndex(self)
      count = dataSource!.numberOfTabsInExpandTabBar(self)
      for index in 0..<count {
        let button = TabBarButton()
        button.setup(self, index: index)
        button.text = dataSource!.expandTabBar(self, itemAtIndex: index)
        button.font = dataSource!.fontOfExpandTabBar(self)
        button.textAlignment = .Center
        button.textColor = UIColor.whiteColor()
        button.backgroundColor = UIColor.clearColor()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.userInteractionEnabled = true
        buttons.append(button)
        addSubview(button)
        button.snp_makeConstraints { make in
          make.centerX.equalTo(self).multipliedBy(CGFloat(1 + 2 * index) / CGFloat(count))
          make.centerY.equalTo(self)
          make.width.equalTo(self).multipliedBy(1.0 / CGFloat(count))
          make.height.equalTo(self)
        }
        if index != selectedIndex {
          button.transform = CGAffineTransformMakeScale(0.75, 0.75)
        }
      }
    }
  }
  
  func tapped(index: Int) {
    buttons[selectedIndex].transform = CGAffineTransformMakeScale(0.75, 0.75)
    selectedIndex = index
    buttons[selectedIndex].transform = CGAffineTransformMakeScale(1, 1)
    delegate?.expandTabBar(self, didSelect: index)
  }
  
  class TabBarButton: UILabel {
    
    var expandTabBar: ExpandTabBar?
    var index: Int = 0
    
    func setup(expandTabBar: ExpandTabBar, index: Int) {
      self.expandTabBar = expandTabBar
      self.index = index
      addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
      expandTabBar!.tapped(index)
    }
    
  }
  
}
