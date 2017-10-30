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
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var closeButton: UIButton!
  
  let dailyButton = UIButton(type: .system)
  let weeklyButton = UIButton(type: .system)
  let monthlyButton = UIButton(type: .system)
  let dailyLabel = UIButton()
  let weeklyLabel = UIButton()
  let monthlyLabel = UIButton()
  let createHabitTransition: UIViewControllerTransitioningDelegate = CreateHabitTransition()
  var timer: Timer?
  
  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let buildButton = { (button: UIButton, text: String, frame: CGRect, action: Selector) in
      button.frame = frame
      button.setTitle(text, for: .normal)
      button.setTitleColor(UIColor.white, for: .normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 20)!
      button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
      button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
      button.roundify(radius: button.frame.width / 2)
      button.backgroundColor = HabitApp.color
      self.view.addSubview(button)
      self.view.bringSubview(toFront: button)
    }
    
    let buildLabel = { (label: UIButton, text: String) in
      label.setTitle(text, for: .normal)
      label.setTitleColor(HabitApp.color, for: .normal)
      label.titleLabel!.font = FontManager.regular(size: 17)
      label.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      label.roundify(radius: 10)
      label.backgroundColor = UIColor.white
      label.sizeToFit()
      label.isHidden = true
      self.view.addSubview(label)
      self.view.bringSubview(toFront: label)
    }
    
    let mvc = presentingViewController as! MainViewController
    closeButton.roundify(radius: closeButton.frame.width / 2)
    closeButton.backgroundColor = HabitApp.color
    let startFrame = CGRect(x: mvc.newButton.center.x - 23, y:  mvc.newButton.center.y - 23, width:  46, height:  46)
    buildButton(dailyButton, "D", startFrame, #selector(SelectFrequencyViewController.buttonDTapped))
    buildButton(weeklyButton, "W", startFrame, #selector(SelectFrequencyViewController.buttonWTapped))
    buildButton(monthlyButton, "M", startFrame, #selector(SelectFrequencyViewController.buttonMTapped))
    buildLabel(dailyLabel, "Daily")
    buildLabel(weeklyLabel, "Weekly")
    buildLabel(monthlyLabel, "Monthly")
    view.bringSubview(toFront: closeButton)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    timer = Timer.scheduledTimer(timeInterval: 5,
                                 target: self,
                                 selector: #selector(SelectFrequencyViewController.showLabels),
                                 userInfo: nil,
                                 repeats: false)
    
    view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                     action: #selector(SelectFrequencyViewController.exit)))
    closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(SelectFrequencyViewController.exit)))
  }
  
  @objc func exit() {
    dismiss(animated: true, completion: nil)
  }
  
  private func curvedAnimation(button: UIButton, start: CGPoint, end: CGPoint, control: CGPoint) {
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.duration = Constants.TransitionDuration
    let path = UIBezierPath()
    path.move(to: start)
    path.addQuadCurve(to: end, controlPoint: control)
    animation.path = path.cgPath
    button.layer.add(animation, forKey: nil)
    button.center = end
  }
  
  func showButtons() {
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(Double.pi / 4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(button: dailyButton,
      start: mvc.newButton.center,
      end: CGPoint(x: mvc.newButton.center.x, y:  mvc.newButton.center.y - ButtonRadius),
      control: CGPoint(x: mvc.newButton.center.x - ButtonRadius / 2, y:  mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(button: weeklyButton,
      start: mvc.newButton.center,
      end: CGPoint(x: mvc.newButton.center.x - shortSide, y:  mvc.newButton.center.y - shortSide),
      control: CGPoint(x: mvc.newButton.center.x - shortSide, y:  mvc.newButton.center.y))
    curvedAnimation(button: monthlyButton,
      start: mvc.newButton.center,
      end: CGPoint(x: mvc.newButton.center.x - ButtonRadius, y:  mvc.newButton.center.y),
      control: CGPoint(x: mvc.newButton.center.x - ButtonRadius / 2, y:  mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func hideButtons() {
    hideLabels()
    let shortSide: CGFloat = ButtonRadius * CGFloat(cos(Double.pi / 4))
    let mvc = presentingViewController as! MainViewController
    curvedAnimation(button: dailyButton, start: dailyButton.center, end: mvc.newButton.center,
      control: CGPoint(x: mvc.newButton.center.x - ButtonRadius / 2, y:  mvc.newButton.center.y - ButtonRadius / 2))
    curvedAnimation(button: weeklyButton, start: weeklyButton.center, end: mvc.newButton.center,
      control: CGPoint(x: mvc.newButton.center.x - shortSide, y:  mvc.newButton.center.y))
    curvedAnimation(button: monthlyButton, start: monthlyButton.center, end: mvc.newButton.center,
      control: CGPoint(x: mvc.newButton.center.x - ButtonRadius / 2, y:  mvc.newButton.center.y + ButtonRadius / 2))
  }
  
  func createHabit(frequency: Habit.Frequency) {
    timer?.invalidate()
    
    for recognizer in view.gestureRecognizers! {
      view.removeGestureRecognizer(recognizer)
    }
    
    let ehvc = EditHabitViewController(nibName: "EditHabitViewController", bundle: nil)
    ehvc.frequency = frequency
    ehvc.modalPresentationStyle = .custom
    ehvc.transitioningDelegate = createHabitTransition
    present(ehvc, animated: true, completion: nil)
  }
  
  @objc func buttonDTapped() { createHabit(frequency: .Daily) }
  @objc func buttonWTapped() { createHabit(frequency: .Weekly) }
  @objc func buttonMTapped() { createHabit(frequency: .Monthly) }
  
  @objc func showLabels() {
    let showLabel = { (label: UIButton, start: CGPoint, end: CGPoint) in
      label.isHidden = false
      label.center = start
      label.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
      UIView.animate(withDuration: Constants.TransitionDuration,
        delay: 0,
        usingSpringWithDamping: 0.5,
        initialSpringVelocity: 1,
        options: [],
        animations: {
          label.center = end
          label.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    let shortSide: CGFloat = LabelDistance * CGFloat(cos(Double.pi / 4))

    showLabel(dailyLabel,
              dailyButton.center,
              CGPoint(x: dailyButton.center.x, y:  dailyButton.center.y - LabelDistance * 0.7))
    showLabel(weeklyLabel,
              weeklyButton.center,
              CGPoint(x: weeklyButton.center.x - shortSide, y:  weeklyButton.center.y - shortSide * 0.7))
    showLabel(monthlyLabel,
              monthlyButton.center,
              CGPoint(x: monthlyButton.center.x - LabelDistance, y:  monthlyButton.center.y))
  }
  
  func hideLabels() {
    let hideLabel = { (label: UIButton, location: CGPoint)  in
      UIView.animate(withDuration: Constants.TransitionDuration,
        animations: {
          label.center = location
          label.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in
          label.isHidden = true
      })
    }
    
    hideLabel(dailyLabel, dailyButton.center)
    hideLabel(weeklyLabel, weeklyButton.center)
    hideLabel(monthlyLabel, monthlyButton.center)
  }
  
}
