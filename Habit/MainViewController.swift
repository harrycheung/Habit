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
    
  let SlideAnimationDelay: NSTimeInterval = 0.05
  let SlideAnimationDuration: NSTimeInterval = 0.4

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var settings: UIButton!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var tabBar: ExpandTabBar!
  @IBOutlet weak var newButton: UIButton!
  @IBOutlet weak var transitionOverlay: UIView!
  
  var statusBar: UIView!
  var refreshTimer: NSTimer!
  var stopReload: Bool = false
  let appSettingsTransition: UIViewControllerTransitioningDelegate = SettingsTransition()
  let selectFrequencyTransition: UIViewControllerTransitioningDelegate = SelectFrequencyTransition()
  let showHabitTransition: UIViewControllerTransitioningDelegate = ShowHabitTransition()
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    settings.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    settings.setTitle(String.fontAwesomeIconWithName(.Cog), forState: .Normal)
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    statusBar.backgroundColor = HabitApp.color
    view.addSubview(statusBar)
      
    // Setup timers
    refreshTimer = NSTimer.scheduledTimerWithTimeInterval(60,
                                                          target: self,
                                                          selector: #selector(MainViewController.reload),
                                                          userInfo: nil,
                                                          repeats: true)
    
    // Setup colors
    titleBar.backgroundColor = HabitApp.color
    tabBar.backgroundColor = HabitApp.color
    newButton.backgroundColor = HabitApp.color
    newButton.layer.cornerRadius = newButton.bounds.width / 2
    newButton.layer.shadowColor = UIColor.blackColor().CGColor
    newButton.layer.shadowOpacity = 0.6
    newButton.layer.shadowRadius = 5
    newButton.layer.shadowOffset = CGSizeMake(0, 1)
    newButton.alpha = 0
    
    view.bringSubviewToFront(transitionOverlay)
  }
  
  func reload() {
    if !stopReload {
      HabitManager.reload()
      tableView.reloadData()
    }
  }
  
  @IBAction func showSettings(sender: AnyObject) {
    let asvc = storyboard!.instantiateViewControllerWithIdentifier("AppSettingsViewController") as! SettingsViewController
    asvc.modalPresentationStyle = .OverCurrentContext
    asvc.transitioningDelegate = appSettingsTransition
    presentViewController(asvc, animated: true, completion: nil)
  }
  
  @IBAction func showSelectFrequency(sender: AnyObject) {
    let sfvc = storyboard!.instantiateViewControllerWithIdentifier("SelectFrequencyViewController") as! SelectFrequencyViewController
    sfvc.modalPresentationStyle = .OverCurrentContext
    sfvc.transitioningDelegate = selectFrequencyTransition
    presentViewController(sfvc, animated: true, completion: nil)
  }
  
  func reloadRows(rows: [NSIndexPath]) {
    tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: .None)
  }
  
  func insertRows(rows: [NSIndexPath], completion: (() -> Void)? = nil) {
    if rows.isEmpty {
      completion?()
      return
    }
    
    tableView.insertRowsAtIndexPaths(rows, withRowAnimation: .None)
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      self.tableView.scrollToRowAtIndexPath(rows[0], atScrollPosition: .Top, animated: true)
      completion?()
    }
    var delayStart = 0.0
    for indexPath in rows {
      if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
        self.showCellAnimate(cell, endFrame: self.tableView.rectForRowAtIndexPath(indexPath), delay: delayStart)
        delayStart += self.SlideAnimationDelay
      }
    }
    CATransaction.commit()
  }
  
  func deleteRows(rows: [NSIndexPath], completion: (() -> Void)? = nil) {
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      self.tableView.beginUpdates()
      self.tableView.deleteRowsAtIndexPaths(rows, withRowAnimation: .None)
      self.tableView.endUpdates()
      completion?()
    }

    var delayStart = 0.0
    for indexPath in rows.reverse() {
      if let cell = tableView.cellForRowAtIndexPath(indexPath) {
        hideCellAnimate(cell, delay: delayStart) {
          // Hide cell to stop it from flashing when the tableView is updated
          cell.hidden = true
        }
        delayStart += SlideAnimationDelay
      }
    }
    CATransaction.commit()
  }
  
  private func hideCellAnimate(view: UIView, delay: NSTimeInterval, completion: (() -> Void)?) {
    var endFrame = view.frame
    endFrame.origin.y = view.frame.origin.y + self.tableView.superview!.bounds.height
    UIView.animateWithDuration(SlideAnimationDuration,
      delay: delay,
      options: [.CurveEaseIn],
      animations: {
        view.frame = endFrame
      }, completion: { finished in
        completion?()
      })
  }
  
  private func showCellAnimate(view: UIView, endFrame: CGRect, delay: NSTimeInterval) {
    var startFrame = view.frame
    startFrame.origin.y = endFrame.origin.y + self.tableView.superview!.bounds.height
    view.frame = startFrame
    view.hidden = false
    UIView.animateWithDuration(SlideAnimationDuration,
      delay: delay,
      options: [.CurveEaseOut],
      animations: {
        view.frame = endFrame
      }, completion: nil)
  }
  
  func resetFuture() {
    CATransaction.begin()
    let future = HabitApp.calendar.zeroTime(HabitApp.calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate())!)
    CATransaction.setCompletionBlock() {
      // Create future entries
      self.insertRows(HabitManager.createEntries(after: future, currentDate: NSDate(), habit: nil, save: true))
    }
    
    // Delete future entries
    deleteRows(HabitManager.deleteEntries(after: future, habit: nil))
    CATransaction.commit()
  }
  
  // Colors
  
  func changeColor(color: UIColor) {
    //testData()
    
    // Snapshot previous color
    UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, UIScreen.mainScreen().scale)
    view.drawViewHierarchyInRect(UIScreen.mainScreen().bounds, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let imageView = UIImageView(image: image)
    overlayView.addSubview(imageView)
    overlayView.alpha = 1
    view.bringSubviewToFront(overlayView)

    // Change color
    titleBar.backgroundColor = color
    tabBar.backgroundColor = color
    statusBar.backgroundColor = color
    newButton.backgroundColor = color
    tableView.reloadData()
    
    // Animate color change
    UIView.animateWithDuration(Constants.ColorChangeAnimationDuration,
                               delay: 0,
                               options: .CurveEaseInOut,
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
    changeColor(HabitApp.color)
  }

  @IBAction func changeColorRight(sender: AnyObject) {
    let newIndex = HabitApp.colorIndex + 1
    if newIndex == Constants.colors.count {
      HabitApp.colorIndex = 0
    } else {
      HabitApp.colorIndex = newIndex
    }
    changeColor(HabitApp.color)
  }
  
  // UIScrollView
  

  
}

extension MainViewController: ExpandTabBarDelegate {
  
  func fontOfExpandTabBar(expandTabBar: ExpandTabBar) -> UIFont {
    return FontManager.regular(18)
  }
  
  func numberOfTabsInExpandTabBar(expandTabBar: ExpandTabBar) -> Int {
    return 3
  }
  
  func expandTabBar(expandTabBar: ExpandTabBar, itemAtIndex: Int) -> String? {
    switch itemAtIndex {
    case 0:
      return "All habits"
    case 1:
      return "Today"
    case 2:
      return "Tomorrow"
    default:
      return ""
    }
  }
  
  func defaultIndex(expandTabBar: ExpandTabBar) -> Int {
    return 1
  }
  
}

extension MainViewController: ExpandTabBarDataSource {
  
  func expandTabBar(expandTabBar: ExpandTabBar, didSelect: Int) {
    tableView.reloadData()
    
    if didSelect == 0 {
      UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    } else {
      UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 0
      }
    }
  }
  
}
