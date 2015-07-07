//
//  MultiSelectControl.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

@objc(MultiSelectControlDataSource)
protocol MultiSelectControlDataSource {
  
  func fontOfMultiSelectControl(multiselectControl: MultiSelectControl) -> UIFont
  func numberOfItemsInMultiSelectControl(multiSelectControl: MultiSelectControl) -> Int
  func multiSelectControl(multiSelectControl: MultiSelectControl, itemAtIndex: Int) -> String?
  
}

class MultiSelectControl : UIView {
  
  @IBOutlet var dataSource: MultiSelectControlDataSource?
  
  private var segments: [String] = []
  private var count: Int = 0
  private var buttons: [UIButton] = []
  private(set) var selectedIndices: [Int] = []
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {    
    if dataSource != nil {
      count = dataSource!.numberOfItemsInMultiSelectControl(self)
      
      for index in 0..<count {
        let button = UIButton()
        button.setTitle(dataSource!.multiSelectControl(self, itemAtIndex: index), forState: .Normal)
        button.titleLabel!.font = dataSource!.fontOfMultiSelectControl(self)
        button.setTitleColor(MainViewController.blue, forState: .Normal)
        button.setBackgroundColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        button.setBackgroundColor(MainViewController.blue, forState: .Selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        addSubview(button)
        addConstraint(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: CGFloat(1 + 2 * index) / CGFloat(count), constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1 / CGFloat(count), constant: -4))
        button.addTarget(self, action: "itemTapped:", forControlEvents: .TouchUpInside)
        buttons.append(button)
      }
    }
  }
  
  func itemTapped(sender: AnyObject) {
    let button = sender as! UIButton
    if button.selected {
      selectedIndices.removeAtIndex(selectedIndices.indexOf(buttons.indexOf(button)!)!)
    } else {
      selectedIndices.append(buttons.indexOf(button)!)
    }
    button.selected = !button.selected
  }

}