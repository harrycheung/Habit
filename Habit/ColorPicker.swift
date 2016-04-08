//
//  ColorPicker.swift
//  Habit
//
//  Created by harry on 7/22/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc(ColorPickerDelegate)
protocol ColorPickerDelegate {
  
  func colorPicked(colorPicker: ColorPicker, colorIndex: Int)
  
}

@IBDesignable
class ColorPicker: UIView {
  
  @IBOutlet var delegate: ColorPickerDelegate?

  var buttons: [UIButton] = []

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
  }
  
  func configure(colors: [UIColor]) {
    for index in 0..<colors.count {
      let button = ColorPickerButton(diameter: diameter, index: index)
      button.backgroundColor = colors[index]
      buttons.append(button)
      addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint(item: button,
                         attribute: .CenterX,
                         relatedBy: .Equal,
                         toItem: self,
                         attribute: .CenterX,
                         multiplier: (1 + 2 * CGFloat(index)) / CGFloat(colors.count),
                         constant: 0).active = true
      button.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
      button.widthAnchor.constraintEqualToConstant(diameter).active = true
      button.heightAnchor.constraintEqualToConstant(diameter).active = true
      button.addTarget(self, action: #selector(ColorPicker.itemTapped(_:)), forControlEvents: .TouchUpInside)
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

