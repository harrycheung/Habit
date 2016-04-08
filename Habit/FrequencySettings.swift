//
//  HabitWeekly.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import UIKit

@objc protocol FrequencySettingsDelegate {
  
  func frequencySettingsChanged()
  
}

class FrequencySettings: UIView {
  
  let DeactivatedAlpha: CGFloat = 0.2
  let OverlayTransitionDuration: NSTimeInterval = 0.15
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var leftTitle: UILabel!
  @IBOutlet weak var rightTitle: UILabel!
  @IBOutlet weak var timesMultiSelect: MultiSelectControl!
  @IBOutlet weak var partsMultiSelect: MultiSelectControl!
  
  var leftOverlay: OverlayView!
  var rightOverlay: OverlayView!
  var partsItems: [String] = []
  var useTimes: Bool = false
  var delegate: FrequencySettingsDelegate?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(leftTitle leftTitle: String,
                 times: Int,
                 timesColumns: Int,
                 rightTitle: String,
                 partsItems: [String],
                 partsColumns: Int,
                 useTimes: Bool,
                 delegate: FrequencySettingsDelegate?) {
    NSBundle.mainBundle().loadNibNamed(String(FrequencySettings), owner: self, options: nil)
    bounds = view.bounds
    addSubview(view)
    
    self.leftTitle.text = leftTitle
    self.rightTitle.text = rightTitle
    self.partsItems = partsItems
    self.useTimes = useTimes
    self.delegate = delegate
    
    var timesArray: [String] = []
    for i in 1...times {
      timesArray.append(String(i))
    }
    timesMultiSelect.configure(timesArray, numberofColumns: timesColumns, single: true)
    timesMultiSelect.font = FontManager.regular(17)
    timesMultiSelect.tintColor = HabitApp.color
    timesMultiSelect.delegate = self
    partsMultiSelect.configure(partsItems, numberofColumns: partsColumns)
    partsMultiSelect.font = FontManager.regular(17)
    partsMultiSelect.tintColor = HabitApp.color
    partsMultiSelect.delegate = self
    
    leftOverlay = OverlayView(frequencySettings: self)
    leftOverlay.backgroundColor = UIColor.clearColor()
    addSubview(leftOverlay)
    leftOverlay.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: leftOverlay,
                       attribute: .CenterX,
                       relatedBy: .Equal,
                       toItem: view,
                       attribute: .CenterX,
                       multiplier: 0.5,
                       constant: 0).active = true
    leftOverlay.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
    NSLayoutConstraint(item: leftOverlay,
                       attribute: .Width,
                       relatedBy: .Equal,
                       toItem: view,
                       attribute: .Width,
                       multiplier: 0.5,
                       constant: 0).active = true
    leftOverlay.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
    rightOverlay = OverlayView(frequencySettings: self)
    rightOverlay.backgroundColor = UIColor.clearColor()
    addSubview(rightOverlay)
    rightOverlay.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: rightOverlay,
                       attribute: .CenterX,
                       relatedBy: .Equal,
                       toItem: view,
                       attribute: .CenterX,
                       multiplier: 1.5,
                       constant: 0).active = true
    rightOverlay.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
    NSLayoutConstraint(item: rightOverlay,
                       attribute: .Width,
                       relatedBy: .Equal,
                       toItem: view,
                       attribute: .Width,
                       multiplier: 0.5,
                       constant: 0).active = true
    rightOverlay.heightAnchor.constraintEqualToAnchor(view.heightAnchor).active = true
    overlayTouched(useTimes ? leftOverlay : rightOverlay, touched: false)
  }
  
  func overlayTouched(overlayView: OverlayView, touched: Bool = true) {
    if overlayView.isEqual(leftOverlay) {
      useTimes = true
      leftOverlay.alpha = 0
      rightOverlay.alpha = 1
      UIView.animateWithDuration(OverlayTransitionDuration) {
        self.leftTitle.alpha = 1
        self.timesMultiSelect.alpha = 1
        self.rightTitle.alpha = self.DeactivatedAlpha
        self.partsMultiSelect.alpha = self.DeactivatedAlpha
      }
    } else {
      useTimes = false
      leftOverlay.alpha = 1
      rightOverlay.alpha = 0
      UIView.animateWithDuration(OverlayTransitionDuration) {
        self.leftTitle.alpha = self.DeactivatedAlpha
        self.timesMultiSelect.alpha = self.DeactivatedAlpha
        self.rightTitle.alpha = 1
        self.partsMultiSelect.alpha = 1
      }
    }
    if touched {
      delegate?.frequencySettingsChanged()
    }
  }
  
  class OverlayView : UIView {
    
    var frequencySettings: FrequencySettings?
    
    init(frequencySettings: FrequencySettings) {
      super.init(frame: CGRectMake(0, 0, 10, 10))
      self.frequencySettings = frequencySettings
    }

    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      frequencySettings!.overlayTouched(self)
    }
    
  }

}

extension FrequencySettings: MultiSelectControlDelegate {
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, indexSelected: Int) {
    delegate?.frequencySettingsChanged()
  }
  
}
