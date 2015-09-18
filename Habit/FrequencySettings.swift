//
//  HabitWeekly.swift
//  Habit
//
//  Created by harry on 7/1/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

@objc protocol FrequencySettingsDelegate {
  
  func frequencySettingsChanged()
  
}

class FrequencySettings: UIView, UIPickerViewDelegate, UIPickerViewDataSource, MultiSelectControlDelegate, MultiSelectControlDataSource {
  
  let DeactivatedAlpha: CGFloat = 0.2
  let OverlayTransitionDuration: NSTimeInterval = 0.15
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var leftTitle: UILabel!
  @IBOutlet weak var rightTitle: UILabel!
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var multiSelect: MultiSelectControl!
  
  var leftOverlay: OverlayView?
  var rightOverlay: OverlayView?
  var pickerCount: Int = 0
  var multiSelectItems: [String] = []
  var useTimes: Bool = false
  var delegate: FrequencySettingsDelegate?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(leftTitle leftTitle: String, pickerCount: Int, rightTitle: String, multiSelectItems: [String], useTimes: Bool, delegate: FrequencySettingsDelegate?) {
    NSBundle.mainBundle().loadNibNamed("FrequencySettings", owner: self, options: nil)
    bounds = view.bounds
    addSubview(view)
    
    self.leftTitle.text = leftTitle
    self.pickerCount = pickerCount
    self.rightTitle.text = rightTitle
    self.multiSelectItems = multiSelectItems
    self.useTimes = useTimes
    self.delegate = delegate
    
    leftOverlay = OverlayView(frequencySettings: self)
    leftOverlay!.translatesAutoresizingMaskIntoConstraints = false
    leftOverlay!.backgroundColor = UIColor.clearColor()
    addSubview(leftOverlay!)
    leftOverlay!.snp_makeConstraints { (make) in
      make.centerX.equalTo(self).multipliedBy(0.5)
      make.centerY.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.5)
      make.height.equalTo(self)
    }
    rightOverlay = OverlayView(frequencySettings: self)
    rightOverlay!.translatesAutoresizingMaskIntoConstraints = false
    rightOverlay!.backgroundColor = UIColor.clearColor()
    addSubview(rightOverlay!)
    rightOverlay!.snp_makeConstraints { (make) in
      make.centerX.equalTo(self).multipliedBy(1.5)
      make.centerY.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.5)
      make.height.equalTo(self)
    }
    overlayTouched(useTimes ? leftOverlay! : rightOverlay!, touched: false)
  }
  
  func overlayTouched(overlayView: OverlayView, touched: Bool = true) {
    if overlayView.isEqual(leftOverlay) {
      useTimes = true
      leftOverlay!.alpha = 0
      rightOverlay!.alpha = 1
      UIView.animateWithDuration(OverlayTransitionDuration) {
        self.leftTitle.alpha = 1
        self.picker.alpha = 1
        self.rightTitle.alpha = self.DeactivatedAlpha
        self.multiSelect.alpha = self.DeactivatedAlpha
      }
    } else {
      useTimes = false
      leftOverlay!.alpha = 1
      rightOverlay!.alpha = 0
      UIView.animateWithDuration(OverlayTransitionDuration) {
        self.leftTitle.alpha = self.DeactivatedAlpha
        self.picker.alpha = self.DeactivatedAlpha
        self.rightTitle.alpha = 1
        self.multiSelect.alpha = 1
      }
    }
    if touched {
      delegate?.frequencySettingsChanged()
    }
  }
  
  // UIPickerView
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerCount
  }
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return NSAttributedString(string: String(row + 1), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    delegate?.frequencySettingsChanged()
  }
  
  // MultiSelectControl
  
  func numberOfItemsInMultiSelectControl(multiSelectControl: MultiSelectControl) -> Int {
    return multiSelectItems.count
  }
  
  func fontOfMultiSelectControl(multiselectControl: MultiSelectControl) -> UIFont {
    return UIFont(name: "Bariol-Regular", size: 17)!
  }
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, itemAtIndex index: Int) -> String? {
    return multiSelectItems[index]
  }
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, didChangeIndexes: [Int]) {
    delegate?.frequencySettingsChanged()
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