//
//  ExpandTabBar.swift
//  Habit
//
//  Created by harry on 12/11/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

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
        button.userInteractionEnabled = true
        buttons.append(button)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: button,
                           attribute: .CenterX,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .CenterX,
                           multiplier: (1 + 2 * CGFloat(index)) / CGFloat(count),
                           constant: 0).active = true
        button.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        NSLayoutConstraint(item: button,
                           attribute: .Width,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .Width,
                           multiplier: 1 / CGFloat(count),
                           constant: 0).active = true
        button.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
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
      addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExpandTabBar.tapped(_:))))
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
      expandTabBar!.tapped(index)
    }
    
  }
  
}
