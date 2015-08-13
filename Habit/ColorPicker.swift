//
//  ColorPicker.swift
//  Habit
//
//  Created by harry on 7/22/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit

@objc(ColorPickerDataSource)
protocol ColorPickerDataSource {
  
  func colorPicker(colorPicker: ColorPicker, colorAtIndex: Int) -> UIColor
  
}

@objc(ColorPickerDelegate)
protocol ColorPickerDelegate {
  
  func colorPicked(colorPicker: ColorPicker, colorIndex: Int)
  
}

@IBDesignable
class ColorPicker: UIView {
  
  @IBOutlet var dataSource: ColorPickerDataSource?
  @IBOutlet var delegate: ColorPickerDelegate?

  var buttons: [UIButton] = []

  @IBInspectable var count: Int = 6
  @IBInspectable var diameter: CGFloat = 40
  
  var selectedIndex: Int {
    get {
      for (index, button) in buttons.enumerate() {
        if button.selected {
          return index
        }
      }
      return -1
    }
    set {
      for (index, button) in buttons.enumerate() {
        button.selected = index == newValue
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    for index in 0..<count {
      let button = ColorPickerButton(diameter: diameter, index: index)
      buttons.append(button)
      addSubview(button)
      button.snp_makeConstraints({ (make) in
        make.centerX.equalTo(self).multipliedBy(CGFloat(1 + 2 * index) / CGFloat(count))
        make.centerY.equalTo(self)
        make.width.height.equalTo(diameter)
      })
      button.addTarget(self, action: "itemTapped:", forControlEvents: .TouchUpInside)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override func layoutSubviews() {
    for (index, button) in buttons.enumerate() {
      button.backgroundColor = dataSource!.colorPicker(self, colorAtIndex: index)
    }
  }
  
  func itemTapped(sender: AnyObject) {
    let clickedButton = sender as! ColorPickerButton
    for (index, button) in buttons.enumerate() {
      if index == clickedButton.index {
        button.selected = true
        delegate?.colorPicked(self, colorIndex: index)
      } else {
        button.selected = false
      }
    }
  }
  
  class ColorPickerButton: UIButton {
    
    var index: Int
    
    init(diameter: CGFloat, index: Int) {
      self.index = index
      super.init(frame: CGRectMake(0, 0, 0, 0))
      
      setTitle("", forState: .Normal)
      translatesAutoresizingMaskIntoConstraints = false
      layer.cornerRadius = diameter / 2
      layer.borderWidth = 1.5
      layer.borderColor = UIColor.clearColor().CGColor
      layer.shadowColor = UIColor.blackColor().CGColor
      layer.shadowOpacity = 0.5
      layer.shadowRadius = 3
      layer.shadowOffset = CGSizeMake(0, 1)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
      get {
        return super.selected
      }
      set {
        super.selected = newValue
          
        if newValue {
          layer.borderColor = UIColor.whiteColor().CGColor
        } else {
          layer.borderColor = UIColor.clearColor().CGColor
        }
      }
    }
    
  }
    
}

