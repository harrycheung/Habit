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

class FrequencySettings : UIView, UIPickerViewDelegate, UIPickerViewDataSource, MultiSelectControlDataSource {
  
  let deactivatedAlpha: CGFloat = 0.8
  
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var leftTitle: UILabel!
  @IBOutlet weak var rightTitle: UILabel!
  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var multiSelect: MultiSelectControl!
  
  var leftOverlay: OverlayView?
  var rightOverlay: OverlayView?
  var pickerCount: Int = 0
  var multiSelectItems: [String] = []
  
  init(leftTitle: String, pickerCount: Int, rightTitle: String, multiSelectItems: [String]) {
    super.init(frame: CGRectMake(0, 0, 1, 1))
    NSBundle.mainBundle().loadNibNamed("FrequencySettings", owner: self, options: nil)
    bounds = view.bounds
    addSubview(view)
    
    self.leftTitle.text = leftTitle
    self.pickerCount = pickerCount
    self.rightTitle.text = rightTitle
    self.multiSelectItems = multiSelectItems
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    leftOverlay = OverlayView(frequencySettings: self)
    leftOverlay!.translatesAutoresizingMaskIntoConstraints = false
    leftOverlay!.backgroundColor = UIColor.whiteColor()
    addSubview(leftOverlay!)
    leftOverlay!.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(self).multipliedBy(0.5)
      make.centerY.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.5).offset(-2)
      make.height.equalTo(self)
    }
    rightOverlay = OverlayView(frequencySettings: self)
    rightOverlay!.translatesAutoresizingMaskIntoConstraints = false
    rightOverlay!.backgroundColor = UIColor.whiteColor()
    addSubview(rightOverlay!)
    rightOverlay!.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(self).multipliedBy(1.5)
      make.centerY.equalTo(self)
      make.width.equalTo(self).multipliedBy(0.5).offset(-2)
      make.height.equalTo(self)
    }
    overlayTouched(leftOverlay!)
  }
  
  func overlayTouched(overlayView: OverlayView) {
    if overlayView.isEqual(leftOverlay) {
      leftOverlay!.alpha = 0
      leftOverlay!.active = true
      rightOverlay!.alpha = deactivatedAlpha
      rightOverlay!.active = false
    } else {
      leftOverlay!.alpha = deactivatedAlpha
      leftOverlay!.active = false
      rightOverlay!.alpha = 0
      rightOverlay!.active = true
    }
  }
  
  // UIPickerView
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerCount
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(row + 1)
  }
  
  // MultiSelectControl
  
  func numberOfItemsInMultiSelectControl(multiSelectControl: MultiSelectControl) -> Int {
    return multiSelectItems.count
  }
  
  func fontOfMultiSelectControl(multiselectControl: MultiSelectControl) -> UIFont {
    return UIFont(name: "Bariol-Regular", size: 20)!
  }
  
  func multiSelectControl(multiSelectControl: MultiSelectControl, itemAtIndex index: Int) -> String? {
    return multiSelectItems[index]
  }
  
  class OverlayView : UIView {
    
    var frequencySettings: FrequencySettings?
    var active: Bool = false
    
    init(frequencySettings: FrequencySettings) {
      super.init(frame: CGRectMake(0, 0, 10, 10))
      self.frequencySettings = frequencySettings
      active = false
    }

    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      frequencySettings!.overlayTouched(self)
    }
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//      let hitView = super.hitTest(point, withEvent: event)
//      if hitView != nil && hitView!.isEqual(self) {
//        // Activate the view that was touched and return nil to pass the event up higher
//        if !active {
//          habitWeekly!.overlayTouched(self)
//        }
//        return nil
//      } else {
//        return hitView
//      }
//    }
    
  }

}