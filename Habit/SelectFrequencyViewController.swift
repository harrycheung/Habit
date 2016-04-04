//
//  SelectFrequencyViewController.swift
//  Habit
//
//  Created by harry on 9/8/15.
//  Copyright © 2015 Harry Cheung. All rights reserved.
//

import CoreData
import FontAwesome_swift

class SelectFrequencyViewController: UIViewController {
  
  let ButtonRadius: CGFloat = 80
  let LabelDistance: CGFloat = 80
  
  @IBOutlet weak var closeButton: UIButton!
  
  let dailyButton = UIButton(type: .System)
  let weeklyButton = UIButton(type: .System)
  let monthlyButton = UIButton(type: .System)
  let dailyLabel = UIButton()
  let weeklyLabel = UIButton()
  let monthlyLabel = UIButton()
  let createHabitTransition: UIViewControllerTransitioningDelegate = CreateHabitTransition()
  var timer: NSTimer?
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let buildButton = { (button: UIButton, text: String, frame: CGRect) in
      button.frame = frame
      button.setTitle(text, forState: .Normal)
      button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 20)!
      button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
      button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("button\(text)Tapped")))
      button.roundify(button.frame.width / 2)
      button.backgroundColor = HabitApp.color
      self.view.addSubview(button)
      self.view.bringSubviewToFront(button)
    }
    
    let buildLabel = { (label: UIButton, text: String) in
      label.setTitle(text, forState: .Normal)
      label.setTitleColor(HabitApp.color, forState: .Normal)
      label.titleLabel!.font = FontManager.regular(17)
      label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      label.roundify(10)
      label.backgroundColor = UIColor.whiteColor()
      label.sizeToFit()
      label.hidden = true
      self.view.addSubview(label)
      self.view.bringSubviewToFront(label)
    }
    
    let mvc = presentingViewController as! MainViewController
    closeButton.roundify(closeButton.frame.width / 2)
    closeButton.backgroundColor = HabitApp.color
    let startFrame = CGRectMake(mvc.newButton.center.x - 23, mvc.newButton.center.y - 23, 46, 46)
    buildButton(dailyButton, "D", startFrame)
    buildButton(weeklyButton, "W", startFrame)
    buildButton(monthlyButton, "M", startFrame)
    buildLabel(dailyLabel, "Daily")
    buildLabel(weeklyLabel, "Weekly")
    buildLabel(monthlyLabel, "Monthly")
    view.bringSubviewToFront(closeButton)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    timer = NSTimer.scheduledTimerWithTimeInterval(5,
                                                   target: self,
                                                   selector: #selector(SelectFrequencyViewController.showLabels),
                                                   userInfo: nil,
                                                   repeats: false)
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(SelectFrequencyViewController.exit)))
    closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(SelectFrequencyViewController.exit)))
  }
  
  func exit() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func curvedAnimation(button: UIButton, start: CGPoint, end: CGPoint, control: CGPoint) {
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.duration = Constants.TransitionDuration
    let path = UIBezierPath()
    path.moveToPoint(start)
    path.addQuadCurveToPoint(end, controlPoint: control)
    animation.path = path.CGPath
    button.layer.addAnimation(animation, forKey: nil)
    button.center = end
  }
  
  func showButtons() {
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x, mvc.newButton.center.y - ButtonRadius),
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(weeklyButton,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y - shortSide),
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton,
      start: mvc.newButton.center,
      end: CGPointMake(mvc.newButton.center.x - ButtonRadius, mvc.newButton.center.y),
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func hideButtons() {
    hideLabels()
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(M_PI_4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(dailyButton, start: dailyButton.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(weeklyButton, start: weeklyButton.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - shortSide, mvc.newButton.center.y))
    curvedAnimation(monthlyButton, start: monthlyButton.center, end: mvc.newButton.center,
      control: CGPointMake(mvc.newButton.center.x - ButtonRadius / 2, mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func createHabit(frequency: Habit.Frequency) {
    timer?.invalidate()
    
    for recognizer in view.gestureRecognizers! {
      view.removeGestureRecognizer(recognizer)
    }
    
    let ehvc = self.storyboard!.instantiateViewControllerWithIdentifier("EditHabitViewController") as! EditHabitViewController
    ehvc.frequency = frequency
    ehvc.modalPresentationStyle = .Custom
    ehvc.transitioningDelegate = createHabitTransition
    presentViewController(ehvc, animated: true, completion: nil)
  }
  
  func buttonDTapped() { createHabit(.Daily) }
  func buttonWTapped() { createHabit(.Weekly) }
  func buttonMTapped() { createHabit(.Monthly) }
  
  func showLabels() {
    let showLabel = { (label: UIButton, start: CGPoint, end: CGPoint) in
      label.hidden = false
      label.center = start
      label.transform = CGAffineTransformMakeScale(0.01, 0.01)
      UIView.animateWithDuration(Constants.TransitionDuration,
        delay: 0,
        usingSpringWithDamping: 0.5,
        initialSpringVelocity: 1,
        options: [],
        animations: {
          label.center = end
          label.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: nil)
    }
    
    let shortSide: CGFloat = LabelDistance * CGFloat(cos(M_PI_4))

    showLabel(dailyLabel,
              dailyButton.center,
              CGPointMake(dailyButton.center.x, dailyButton.center.y - LabelDistance * 0.7))
    showLabel(weeklyLabel,
              weeklyButton.center,
              CGPointMake(weeklyButton.center.x - shortSide, weeklyButton.center.y - shortSide * 0.7))
    showLabel(monthlyLabel,
              monthlyButton.center,
              CGPointMake(monthlyButton.center.x - LabelDistance, monthlyButton.center.y))
  }
  
  func hideLabels() {
    let hideLabel = { (label: UIButton, location: CGPoint)  in
      UIView.animateWithDuration(Constants.TransitionDuration,
        animations: {
          label.center = location
          label.transform = CGAffineTransformMakeScale(0.01, 0.01)
        }, completion: { finished in
          label.hidden = true
      })
    }
    
    hideLabel(dailyLabel, dailyButton.center)
    hideLabel(weeklyLabel, weeklyButton.center)
    hideLabel(monthlyLabel, monthlyButton.center)
  }
  
}
