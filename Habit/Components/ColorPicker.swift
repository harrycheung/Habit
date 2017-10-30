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
      for (index, button) in buttons.enumerated() {
        if button.isSelected {
          return index
        }
      }
      return -1
    }
    set {
      for (index, button) in buttons.enumerated() {
        button.isSelected = index == newValue
      }
    }
  }
    
  override init(frame: CGRect) {
    super.init(frame: frame)
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
                         attribute: .centerX,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerX,
                         multiplier: (1 + 2 * CGFloat(index)) / CGFloat(colors.count),
                         constant: 0).isActive = true
      button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
      button.widthAnchor.constraint(equalToConstant: diameter).isActive = true
      button.heightAnchor.constraint(equalToConstant: diameter).isActive = true
      button.addTarget(self, action: #selector(ColorPicker.itemTapped), for: .touchUpInside)
    }
  }
  
  @objc func itemTapped(sender: AnyObject) {
    let clickedButton = sender as! ColorPickerButton
    for (index, button) in buttons.enumerated() {
      if index == clickedButton.index {
        button.isSelected = true
        delegate?.colorPicked(colorPicker: self, colorIndex: index)
      } else {
        button.isSelected = false
      }
    }
  }
  
  class ColorPickerButton: UIButton {
    
    var index: Int
    
    init(diameter: CGFloat, index: Int) {
      self.index = index
      super.init(frame: CGRect(x: 0, y:  0, width:  0, height:  0))
      
      setTitle("", for: .normal)
      translatesAutoresizingMaskIntoConstraints = false
      layer.cornerRadius = diameter / 2
      layer.borderWidth = 1.5
      layer.borderColor = UIColor.clear.cgColor
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOpacity = 0.5
      layer.shadowRadius = 3
      layer.shadowOffset = CGSize(width: 0, height: 1)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
      get {
        return super.isSelected
      }
      set {
        super.isSelected = newValue
          
        if newValue {
          layer.borderColor = UIColor.white.cgColor
        } else {
          layer.borderColor = UIColor.clear.cgColor
        }
      }
    }
    
  }
    
}

