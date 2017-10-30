//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import FontAwesome_swift

class MainViewController: UIViewController {
    
  let SlideAnimationDelay: TimeInterval = 0.05
  let SlideAnimationDuration: TimeInterval = 0.4

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var statusBar: UIView!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var settings: UIButton!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var newButton: UIButton!
  @IBOutlet weak var transitionOverlay: UIView!
  
  var refreshTimer: Timer!
  var stopReload: Bool = false
  let settingsTransition: UIViewControllerTransitioningDelegate = SettingsTransition()
  let selectFrequencyTransition: UIViewControllerTransitioningDelegate = SelectFrequencyTransition()
  let showHabitTransition: UIViewControllerTransitioningDelegate = ShowHabitTransition()
  
  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    settings.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
    settings.setTitle(String.fontAwesomeIcon(name: .cog), for: .normal)
    
    statusBar.backgroundColor = HabitApp.color
    
    // Setup timers
    refreshTimer = Timer.scheduledTimer(timeInterval: 60,
                                                          target: self,
                                                          selector: #selector(MainViewController.reload),
                                                          userInfo: nil,
                                                          repeats: true)
    
    // Setup colors
    titleBar.backgroundColor = HabitApp.color
    newButton.backgroundColor = HabitApp.color
    newButton.layer.cornerRadius = newButton.bounds.width / 2
    newButton.layer.shadowColor = UIColor.black.cgColor
    newButton.layer.shadowOpacity = 0.6
    newButton.layer.shadowRadius = 5
    newButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    
    view.bringSubview(toFront: transitionOverlay)
  }
  
  @objc func reload() {
    if !stopReload {
      HabitManager.reload()
      tableView.reloadData()
    }
  }
  
  @IBAction func showSettings(sender: AnyObject) {
    let svc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
    svc.modalPresentationStyle = .overCurrentContext
    svc.transitioningDelegate = settingsTransition
    present(svc, animated: true, completion: nil)
  }
  
  @IBAction func showSelectFrequency(sender: AnyObject) {
    //let sfvc = storyboard!.instantiateViewControllerWithIdentifier(String(SelectFrequencyViewController)) as! SelectFrequencyViewController
    let sfvc = SelectFrequencyViewController(nibName: "SelectFrequencyViewController", bundle: nil)
    sfvc.modalPresentationStyle = .overCurrentContext
    sfvc.transitioningDelegate = selectFrequencyTransition
    present(sfvc, animated: true, completion: nil)
  }
  
  func reloadRows(rows: [IndexPath]) {
    tableView.reloadRows(at: rows, with: .none)
  }
  
  func insertRows(rows: [IndexPath], completion: (() -> Void)? = nil) {
    if rows.isEmpty {
      completion?()
      return
    }
    
    tableView.insertRows(at: rows, with: .none)
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      self.tableView.scrollToRow(at: rows[0], at: .top, animated: true)
      completion?()
    }
    var delayStart = 0.0
    for indexPath in rows {
      if let cell = self.tableView.cellForRow(at: indexPath) {
        self.showCellAnimate(view: cell, endFrame: self.tableView.rectForRow(at: indexPath), delay: delayStart)
        delayStart += self.SlideAnimationDelay
      }
    }
    CATransaction.commit()
  }
  
  func deleteRows(rows: [IndexPath], completion: (() -> Void)? = nil) {
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      self.tableView.beginUpdates()
      self.tableView.deleteRows(at: rows, with: .none)
      self.tableView.endUpdates()
      completion?()
    }

    var delayStart = 0.0
    for indexPath in rows.reversed() {
      if let cell = tableView.cellForRow(at: indexPath) {
        hideCellAnimate(view: cell, delay: delayStart) {
          // Hide cell to stop it from flashing when the tableView is updated
          cell.isHidden = true
        }
        delayStart += SlideAnimationDelay
      }
    }
    CATransaction.commit()
  }
  
  private func hideCellAnimate(view: UIView, delay: TimeInterval, completion: (() -> Void)?) {
    var endFrame = view.frame
    endFrame.origin.y = view.frame.origin.y + self.tableView.superview!.bounds.height
    UIView.animate(withDuration: SlideAnimationDuration,
      delay: delay,
      options: [.curveEaseIn],
      animations: {
        view.frame = endFrame
      }, completion: { finished in
        completion?()
      })
  }
  
  private func showCellAnimate(view: UIView, endFrame: CGRect, delay: TimeInterval) {
    var startFrame = view.frame
    startFrame.origin.y = endFrame.origin.y + self.tableView.superview!.bounds.height
    view.frame = startFrame
    view.isHidden = false
    UIView.animate(withDuration: SlideAnimationDuration,
      delay: delay,
      options: [.curveEaseOut],
      animations: {
        view.frame = endFrame
      }, completion: nil)
  }
  
  // Colors
  
  func changeColor(color: UIColor) {
    //testData()
    
    // Snapshot previous color
    UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
    view.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let imageView = UIImageView(image: image)
    overlayView.addSubview(imageView)
    overlayView.alpha = 1
    view.bringSubview(toFront: overlayView)

    // Change color
    titleBar.backgroundColor = color
    statusBar.backgroundColor = color
    newButton.backgroundColor = color
    tableView.reloadData()
    
    // Animate color change
    UIView.animate(withDuration: Constants.ColorChangeAnimationDuration,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                                 self.overlayView.alpha = 0
                               },
                               completion: { finished in
                                 imageView.removeFromSuperview()
                               })
  }
  
  @IBAction func changeColorLeft(sender: AnyObject) {
    let newIndex = HabitApp.colorIndex - 1
    if newIndex == -1 {
      HabitApp.colorIndex = Constants.colors.count - 1
    } else {
      HabitApp.colorIndex = newIndex
    }
    changeColor(color: HabitApp.color)
  }

  @IBAction func changeColorRight(sender: AnyObject) {
    let newIndex = HabitApp.colorIndex + 1
    if newIndex == Constants.colors.count {
      HabitApp.colorIndex = 0
    } else {
      HabitApp.colorIndex = newIndex
    }
    changeColor(color: HabitApp.color)
  }
  
}

extension MainViewController: UITabBarDelegate {
  
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    tableView.reloadData()
    
    if item.title == Constants.TabAll {
      UIView.animate(withDuration: Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    } else {
      UIView.animate(withDuration: Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 0
      }
    }
  }
  
}
