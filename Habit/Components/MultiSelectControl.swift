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
        buttons[index].isSelected = true
      }
    }
  }
  
  var font: UIFont = UIFont.systemFont(ofSize: 17) {
    didSet {
      for button in buttons {
        button.titleLabel!.font = font
      }
    }
  }
  
  override var tintColor: UIColor! {
    didSet {
      for button in buttons {
        button.setTitleColor(tintColor, for: .selected)
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
      button.setTitle(items[index], for: .normal)
      button.titleLabel!.font = font
      button.setTitleColor(UIColor.white, for: .normal)
      button.setBackgroundColor(color: UIColor.clear, forState: .normal)
      button.setTitleColor(tintColor, for: .selected)
      button.setBackgroundColor(color: UIColor.white, forState: .selected)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.layer.cornerRadius = 3
      button.layer.masksToBounds = true
      buttons.append(button)
      addSubview(button)
      button.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint(item: button,
                         attribute: .centerX,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerX,
                         multiplier: (1 + 2 * CGFloat(index % columns)) / CGFloat(columns),
                         constant: 0).isActive = true
      NSLayoutConstraint(item: button,
                         attribute: .centerY,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerY,
                         multiplier: (1 + 2 * CGFloat(index / columns)) / rows,
                         constant: 0).isActive = true
      button.widthAnchor.constraint(equalTo: widthAnchor,
                                    multiplier: 1.0 / CGFloat(columns),
                                    constant: columns == 0 ? 0 : -3).isActive = true
      button.heightAnchor.constraint(equalTo: heightAnchor,
                                     multiplier: 1.0 / rows,
                                     constant: -3).isActive = true
      button.addTarget(self, action: #selector(MultiSelectControl.itemTapped), for: .touchUpInside)
      if selectedIndexes.contains(index) {
        button.isSelected = true
      }
    }
  }
  
  @objc func itemTapped(sender: AnyObject) {
    let tapped = sender as! UIButton
    tapped.isSelected = !tapped.isSelected
    
    if tapped.isSelected && single {
      for button in buttons {
        button.isSelected = button == tapped
      }
    }
    
    selectedIndexes = buttons.enumerated().map { (index, button) in
      return button.isSelected ? index : -1
    }.filter { $0 > -1 }
    
    delegate?.multiSelectControl(multiSelectControl: self, indexSelected: buttons.index(of: tapped)!)
  }

}
