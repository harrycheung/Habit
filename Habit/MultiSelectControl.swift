//
//  MultiSelectControl.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc(MultiSelectControlDelegate)
protocol MultiSelectControlDelegate {
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, indexSelected: Int)
  
}

class MultiSelectControl: UIView {
  
  @IBOutlet var delegate: MultiSelectControlDelegate?
  
  private var buttons: [UIButton] = []
  private var single: Bool = false
  
  var selectedIndexes: [Int] = [] {
    didSet {
      for index in selectedIndexes {
        buttons[index].selected = true
      }
    }
  }
  
  var font: UIFont = UIFont.systemFontOfSize(17) {
    didSet {
      for button in buttons {
        button.titleLabel!.font = font
      }
    }
  }
  
  override var tintColor: UIColor! {
    didSet {
      for button in buttons {
        button.setTitleColor(tintColor, forState: .Selected)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(items: [String], numberofColumns columns: Int, single: Bool = false) {
    self.single = single
    let rows = CGFloat(items.count / columns + items.count % columns)
    for index in 0..<items.count {
      let button = UIButton()
      button.setTitle(items[index], forState: .Normal)
      button.titleLabel!.font = font
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
      NSLayoutConstraint(item: button,
                         attribute: .CenterX,
                         relatedBy: .Equal,
                         toItem: self,
                         attribute: .CenterX,
                         multiplier: (1 + 2 * CGFloat(index % columns)) / CGFloat(columns),
                         constant: 0).active = true
      NSLayoutConstraint(item: button,
                         attribute: .CenterY,
                         relatedBy: .Equal,
                         toItem: self,
                         attribute: .CenterY,
                         multiplier: (1 + 2 * CGFloat(index / columns)) / rows,
                         constant: 0).active = true
      button.widthAnchor.constraintEqualToAnchor(widthAnchor,
                                                 multiplier: 1.0 / CGFloat(columns),
                                                 constant: columns == 0 ? 0 : -3).active = true
      button.heightAnchor.constraintEqualToAnchor(heightAnchor,
                                                  multiplier: 1.0 / rows,
                                                  constant: -3).active = true
      button.addTarget(self, action: #selector(MultiSelectControl.itemTapped(_:)), forControlEvents: .TouchUpInside)
      if selectedIndexes.contains(index) {
        button.selected = true
      }
    }
  }
  
  func itemTapped(sender: AnyObject) {
    let tapped = sender as! UIButton
    tapped.selected = !tapped.selected
    
    if tapped.selected && single {
      for button in buttons {
        button.selected = button == tapped
      }
    }
    
    selectedIndexes = buttons.enumerate().map { (index, button) in
      return button.selected ? index : -1
    }.filter { $0 > -1 }
    
    delegate?.multiSelectControl(self, indexSelected: buttons.indexOf(tapped)!)
  }

}
