//
//  MultiSelectControl.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc(MultiSelectControlDataSource)
protocol MultiSelectControlDataSource {
  
  func fontOfMultiSelectControl(multiselectControl: MultiSelectControl) -> UIFont
  func numberOfItemsInMultiSelectControl(multiSelectControl: MultiSelectControl) -> Int
  func multiSelectControl(multiSelectControl: MultiSelectControl, itemAtIndex: Int) -> String?
  
}

@objc(MultiSelectControlDelegate)
protocol MultiSelectControlDelegate {
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, didChangeIndexes: [Int])
  
}

class MultiSelectControl: UIView {
  
  @IBOutlet var dataSource: MultiSelectControlDataSource?
  @IBOutlet var delegate: MultiSelectControlDelegate?
  
  var segments: [String] = []
  var count: Int = 0
  var buttons: [UIButton] = []
  var selectedIndexes: [Int] = []
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // TODO: Is this the right place for adding buttons? The buttons.isEmpty check is necessary.
    // Otherwise, a recursive loop occurs with each button that gets added. The other wasy to "fix" 
    // this is to give the superview a height constraint with priority 1000.
    if dataSource != nil && buttons.isEmpty {
      count = dataSource!.numberOfItemsInMultiSelectControl(self)
      for index in 0..<count {
        let button = UIButton()
        button.setTitle(dataSource!.multiSelectControl(self, itemAtIndex: index), forState: .Normal)
        button.titleLabel!.font = dataSource!.fontOfMultiSelectControl(self)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setBackgroundColor(UIColor.clearColor(), forState: .Normal)
        button.setTitleColor(tintColor, forState: .Selected)
        button.setBackgroundColor(UIColor.whiteColor(), forState: .Selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        buttons.append(button)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        NSLayoutConstraint(item: button,
                           attribute: .CenterY,
                           relatedBy: .Equal,
                           toItem: self,
                           attribute: .CenterY,
                           multiplier: (1 + 2 * CGFloat(index)) / CGFloat(count),
                           constant: 0).active = true
        button.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        button.heightAnchor.constraintEqualToAnchor(heightAnchor,
                                                    multiplier: 1.0 / CGFloat(count), constant: -3).active = true
        button.addTarget(self, action: #selector(MultiSelectControl.itemTapped(_:)), forControlEvents: .TouchUpInside)
        if selectedIndexes.contains(index) {
          button.selected = true
        }
      }
    }
  }
  
  func itemTapped(sender: AnyObject) {
    let button = sender as! UIButton
    if button.selected {
      selectedIndexes.removeAtIndex(selectedIndexes.indexOf(buttons.indexOf(button)!)!)
    } else {
      selectedIndexes.append(buttons.indexOf(button)!)
    }
    button.selected = !button.selected
    delegate?.multiSelectControl(self, didChangeIndexes: selectedIndexes)
  }

}
