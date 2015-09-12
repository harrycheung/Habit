//
//  CreateHabitViewController.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import Foundation
import CoreData
import FontAwesome_swift

class CreateHabitViewController: UIViewController {
  
  @IBOutlet weak var blurView: UIView!
  @IBOutlet weak var closeButton: UIButton!
  var dailyButton: UIButton?
  var weeklyButton: UIButton?
  var monthlyButton: UIButton?
  var createHabitTransition: UIViewControllerTransitioningDelegate?
  
  override func viewDidLoad() {
    let roundifyButton = { (button: UIButton) in
      button.backgroundColor = HabitApp.color
      button.layer.cornerRadius = button.frame.width / 2
      button.layer.shadowColor = UIColor.blackColor().CGColor
      button.layer.shadowOpacity = 0.6
      button.layer.shadowRadius = 5
      button.layer.shadowOffset = CGSizeMake(0, 1)
    }
    
    let createButton = { (text: String, frame: CGRect) -> UIButton in
      let button = UIButton(type: .System)
      button.frame = frame
      button.setTitle(text, forState: .Normal)
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 20)!
      button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
      button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("button\(text)Tapped")))
      roundifyButton(button)
      self.view.addSubview(button)
      return button
    }
    
    let mvc = presentingViewController as! MainViewController
    roundifyButton(closeButton)
    blurView.alpha = 0
    let startFrame = CGRectMake(mvc.newButton.center.x - 23, mvc.newButton.center.y - 23, 46, 46)
    dailyButton = createButton("D", startFrame)
    weeklyButton = createButton("W", startFrame)
    monthlyButton = createButton("M", startFrame)
    view.bringSubviewToFront(closeButton)
    
    createHabitTransition = CreateHabitTransition()
  }
  
  let radius: CGFloat = 100
  
  func curvedAnimation(button: UIButton, start: CGPoint, end: CGPoint, control: CGPoint) {
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.duration = 0.3
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addQuadCurveToPoint(end, controlPoint: control)
    animation.path = path.CGPath
    button.layer.addAnimation(animation, forKey: nil)
    button.center = end
  }
  
  func showButtons() {
    let shortSide: CGFloat = radius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x, mvc.newButton.center.y - radius),
      control: CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y - radius / 2))
    curvedAnimation(weeklyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y - shortSide),
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton!,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - radius, mvc.newButton.center.y),
      control: CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y + radius / 2))
  }
  
  func hideButtons() {
    let shortSide: CGFloat = radius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton!, start: dailyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y - radius / 2))
    curvedAnimation(weeklyButton!, start: weeklyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton!, start: monthlyButton!.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - radius / 2, mvc.newButton.center.y + radius / 2))
  }
  
  func createHabit(frequency: Habit.Frequency) {
    let hsvc = self.storyboard!.instantiateViewControllerWithIdentifier("HabitSettingsViewController") as! HabitSettingsViewController
    hsvc.frequency = frequency
    hsvc.modalPresentationStyle = .Custom
    hsvc.transitioningDelegate = createHabitTransition
    presentViewController(hsvc, animated: true, completion: nil)
  }
  
  func buttonDTapped() { createHabit(.Daily) }
  func buttonWTapped() { createHabit(.Weekly) }
  func buttonMTapped() { createHabit(.Monthly) }
  
}
