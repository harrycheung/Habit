//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

// TODO
//  1. done - Check timezone changes on load
//  2. done - Snooze behavior
//  3. done - Sort habits based on time periods
//  4. done - github style history graph
//  5. done - Habit info page
//  6. done - App settings
//  7. done - Local notifications
//  8. done - Expire habits periodically
//  9. done - Split ShowHabitViewController
// 10. done - Use Entry for tableview
// 11. done - Debug flash when changing color
// 12. done - Debug flash when dismising habit settings
// 13. done - simulator only - Debug flash on color picker button
// 14. done - Clean up AppDelegate
// 15. done - Auto-skip
// 16. done - If a lot to be done, ask to skip all
// 17. done - Pretify show upcoming animation
// 18. done - Pretify insert new habit
// 19. done - not happening - Warn when changing habit frequency and handle
// 20. done - Skip icon
// 21. done - Hide add button when swiping
// 22. done - Switch to gregorian calendar
// 23. done - Fix blank delegate methods
// 24. done - Check to see if a habit of the same name exists
// 25. done - Strip habit name of whitespace
// 26. done - newButton provides frequency options
// 27. done - Option on habit to ignore autoskip
// 28. done - Fix github box moving to left on settings click
// 29. done - Tap outside settings view to close
// 30. done - Animate filling of history box
// 31. done - Custom start and finish day
// 32. done - Icon
// 33: done - Delete history when deleting entries new frequency
// 34: done - Long press on frequency selection shows long word
// 35: done - Start app first time with example habit
// 36: done - Pause habit
// 37: done - Launch screen
// 38: done - Resist swiping upcoming
// 39: done - Show frequency words after 1 second timeout
// 40: done - Fix overlay on frequency selection
// 41: done - Add touch listener to overlay view on MVC
// 42: done - Update pods to xcode 7
// 43: done - Debug hide keyboard in new habit
// 44: done - Fix border in habit history
// 45: done - Call update on habits after return from background
// 46: Use visible cells on tableview to animate
// 47: done - Multiple storyboards for each screen size
// 48: done - Should autoskip happen immediately or later?
// 49: done - Disable input while row animation is happening
// 50: done - Fix blur mask in when editing existing habit
// 51: done - Fix tint colors on dialogs
// 52: done - Dialog to indicate habits were auto skipped?
// 53: done - Stop reload when displaying dialog
// 54: done - Test single paused habit
// 55: done - When skipping past, use swipe animation
// 56: done - Inserting new entries should take account of previous ordering
// 57: Fake habits for review and tell your friends

import UIKit
import CoreData
import FontAwesome_swift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
  
  // IB identifiers
  let cellIdentifier = "HabitCell"
  
  let SlideAnimationDelay: NSTimeInterval = 0.05
  let SlideAnimationDuration: NSTimeInterval = 0.4

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var settings: UIButton!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var newButton: UIButton!
  @IBOutlet weak var transitionOverlay: UIView!
  
  var statusBar: UIView?
  var refreshTimer: NSTimer?
  var stopReload: Bool = false
  let appSettingsTransition: UIViewControllerTransitioningDelegate = AppSettingsTransition()
  let selectFrequencyTransition: UIViewControllerTransitioningDelegate = SelectFrequencyTransition()
  let showHabitTransition: UIViewControllerTransitioningDelegate = ShowHabitTransition()
  
  func testData() {
    do {
      let calendar = HabitApp.calendar
//      var date = calendar.dateByAddingUnit(.WeekOfYear, value: -40, toDate: NSDate())!
//      var h = Habit(context: HabitApp.moContext, name: "5. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: date)
//      h.update(NSDate())
//      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
//        //print(formatter.stringFromDate(date))
//        let entries = h.entriesOnDate(date)
//        //print("c: \(entries.count)")
//        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
//          entries[i].complete()
//        }
//        for entry in entries {
//          if entry.state == .Todo {
//            entry.skip()
//          }
//        }
//        date = NSDate(timeInterval: 24 * 3600 * 7, sinceDate: date)
//      }
//      date = calendar.dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate())!
//      h = Habit(context: HabitApp.moContext, name: "W: Will not show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
//      h.update(NSDate())
//      date = calendar.dateByAddingUnit(.WeekOfYear, value: -5, toDate: NSDate())!
//      h = Habit(context: HabitApp.moContext, name: "W: Will show skip dialog", details: "", frequency: .Weekly, times: 0, createdAt: date)
//      h.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Friday, .Saturday]
//      date = calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date)!
//      h.update(date)
//      h.deleteEntries(after: date)
//      HabitApp.moContext.refreshAllObjects()
//      h.pausedBool = true
//      date = calendar.dateByAddingUnit(.WeekOfYear, value: 2, toDate: date)!
//      h.update(date)
//      h.pausedBool = false
//      h.generateEntries(after: date)
//      h.update(NSDate())
      
      var date = calendar.dateByAddingUnit(.Day, value: -180, toDate: NSDate())!
      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: date)
      h.update(NSDate())
      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
        let entries = h.entriesOnDate(date)
        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
          entries[i].complete()
        }
        for entry in entries {
          if entry.state == .Todo {
            entry.skip()
          }
        }
        date = NSDate(timeInterval: Double(HabitApp.daySec), sinceDate: date)
      }
      
//      let createdAt = calendar.dateByAddingUnit(.Hour, value: 10, toDate: calendar.zeroTime(calendar.dateByAddingUnit(.Day, value: -5, toDate: NSDate())!))!
//      let h = Habit(context: HabitApp.moContext, name: "Drink water", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
//      h.update(NSDate())
//      h.pausedBool = true
//      var date = calendar.dateByAddingUnit(.Day, value: 1, toDate: createdAt)!
//      HabitManager.reload()
//      HabitManager.deleteEntries(after: date, habit: h)
//      HabitApp.moContext.refreshAllObjects()
//      date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
//      h.update(date)
//      h.pausedBool = false
//      date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
//      h.update(date, currentDate: NSDate())
//      date = createdAt
//      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Day) {
//        let entries = h.entriesOnDate(date)
//        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
//          entries[i].complete()
//        }
//        for entry in entries {
//          if entry.state == .Todo {
//            entry.skip()
//          }
//        }
//        date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date)!
//      }
      
//      date = calendar.dateByAddingUnit(.Day, value: -25, toDate: NSDate())!
//      h = Habit(context: HabitApp.moContext, name: "Daily with pause", details: "", frequency: .Daily, times: 12, createdAt: date)
//      date = calendar.dateByAddingUnit(.Day, value: 4, toDate: date)!
//      h.update(date)
//      h.deleteEntries(after: date)
//      HabitApp.moContext.refreshAllObjects()
//      h.pausedBool = true
//      date = calendar.dateByAddingUnit(.Day, value: 7, toDate: date)!
//      h.update(date)
//      h.pausedBool = false
//      h.generateEntries(after: date)
//      h.update(NSDate())

      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    HabitManager.reload()
    tableView.reloadData()
    HabitManager.updateNotifications()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    settings.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    settings.setTitle(String.fontAwesomeIconWithName(.Cog), forState: .Normal)
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    statusBar!.backgroundColor = HabitApp.color
    view.addSubview(statusBar!)
      
    // Setup timers
    refreshTimer =
      NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "reload", userInfo: nil, repeats: true)
    
    // Setup colors
    titleBar.backgroundColor = HabitApp.color
    newButton.backgroundColor = HabitApp.color
    newButton.layer.cornerRadius = newButton.bounds.width / 2
    newButton.layer.shadowColor = UIColor.blackColor().CGColor
    newButton.layer.shadowOpacity = 0.6
    newButton.layer.shadowRadius = 5
    newButton.layer.shadowOffset = CGSizeMake(0, 1)
    
    view.bringSubviewToFront(transitionOverlay)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func reload() {
    if !stopReload {
      HabitManager.reload()
      tableView.reloadData()
    }
  }
  
  @IBAction func showSettings(sender: AnyObject) {
    let asvc = storyboard!.instantiateViewControllerWithIdentifier("AppSettingsViewController") as! AppSettingsViewController
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
    
    tableView.beginUpdates()
    if HabitApp.upcoming {
      if tableView.numberOfSections == 1 {
        tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .None)
      }
      if tableView.numberOfSections < 3 && HabitManager.pausedCount > 0 {
        tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .None)
      }
    }
    tableView.insertRowsAtIndexPaths(rows, withRowAnimation: .None)
    tableView.endUpdates()
    
    CATransaction.begin()
    CATransaction.setCompletionBlock() {
      self.tableView.scrollToRowAtIndexPath(rows[0], atScrollPosition: .Top, animated: true)
      completion?()
    }
    var delayStart = 0.0
    for indexPath in rows {
      if indexPath.row == 0 && indexPath.section > 0 {
        if let header = self.tableView.headerViewForSection(indexPath.section) {
          self.showCellAnimate(header, endFrame: self.tableView.rectForHeaderInSection(indexPath.section), delay: delayStart)
        }
      }
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
      if HabitApp.upcoming {
        if self.tableView.numberOfSections == 3 && HabitManager.pausedCount == 0 {
          self.tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .None)
        }
      } else {
        if self.tableView.numberOfSections > 1 {
          self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .None)
          if self.tableView.numberOfSections == 3 {
            self.tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .None)
          }
        }
      }
      self.tableView.endUpdates()
      completion?()
    }

    var delayStart = 0.0
    for indexPath in rows.reverse() {
      if indexPath.row == 0 && indexPath.section > 0 {
        if !HabitApp.upcoming ||
          (indexPath.section == 1 && HabitManager.upcomingCount == 0) ||
          (indexPath.section == 2 && HabitManager.pausedCount == 0) {
          if let header = tableView.headerViewForSection(indexPath.section) {
            hideCellAnimate(header, delay: delayStart) {
              header.hidden = true
            }
          }
        }
      }
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
  
  func showUpcoming(completion: (() -> Void)?) {
    var rows: [NSIndexPath] = []
    rows += (0..<HabitManager.upcomingCount).map { NSIndexPath(forRow: $0, inSection: 1) }
    rows += (0..<HabitManager.pausedCount).map { NSIndexPath(forRow: $0, inSection: 2) }
    self.insertRows(rows, completion: completion)
  }
  
  func hideUpcoming(completion: (() -> Void)?) {
    var rows: [NSIndexPath] = []
    rows += (0..<HabitManager.upcomingCount).map { NSIndexPath(forRow: $0, inSection: 1) }
    rows += (0..<HabitManager.pausedCount).map { NSIndexPath(forRow: $0, inSection: 2) }
    deleteRows(rows, completion: completion)
  }
  
  func resetFuture() {
    CATransaction.begin()
    let future = HabitApp.calendar.zeroTime(HabitApp.calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate())!)
    CATransaction.setCompletionBlock() {
      // Create future entries
      self.insertRows(HabitManager.createEntries(after: future, currentDate: NSDate(),  habit: nil, save: true))
    }
    
    // Delete future entries
    deleteRows(HabitManager.deleteEntries(after: future, habit: nil))
    CATransaction.commit()
  }
  
  // Table view
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let removeRows = { (indexPaths: [NSIndexPath]) in
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
      UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    }
    
    let complete = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      HabitManager.complete(indexPath.section, index: indexPath.row)
      removeRows([indexPath])
    }
    
    let skip = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      let entry = indexPath.section == 0 ? HabitManager.current[indexPath.row] : HabitManager.upcoming[indexPath.row]
      if !entry.habit!.isFake && entry.habit!.hasOldEntries {
        let sdvc = self.storyboard!.instantiateViewControllerWithIdentifier("SwipeDialogViewController") as! SwipeDialogViewController
        sdvc.modalTransitionStyle = .CrossDissolve
        sdvc.modalPresentationStyle = .OverCurrentContext
        sdvc.yesCompletion = {
          // Single out this entry just in case its due > NSDate()
          if entry.due!.compare(NSDate()) == .OrderedDescending {
            HabitManager.skip(indexPath.section, index: indexPath.row)
          }
          self.dismissViewControllerAnimated(true) {
            removeRows(HabitManager.skip(entry.habit!))
            self.stopReload = false
          }
        }
        sdvc.noCompletion = {
          HabitManager.skip(indexPath.section, index: indexPath.row)
          self.dismissViewControllerAnimated(true) {
            removeRows([indexPath])
            self.stopReload = false
          }
        }
        self.stopReload = true
        self.presentViewController(sdvc, animated: true, completion: nil)
      } else {
        HabitManager.skip(indexPath.section, index: indexPath.row)
        removeRows([indexPath])
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    switch indexPath.section {
    case 0:
      cell.load(entry: HabitManager.current[indexPath.row])
    case 1:
      cell.load(entry: HabitManager.upcoming[indexPath.row])
    case 2:
      cell.load(habit: HabitManager.paused[indexPath.row])
    default: ()
    }
    cell.delegate = self
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.Check, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: HabitApp.green,
      options: [.Rotate, .Alpha],
      completion: { cell in
        complete(cell)
    })
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.History, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: HabitApp.yellow,
      options: [.Rotate, .Alpha],
      completion: { cell in
        skip(cell)
    })
    if indexPath.section == 0 || (cell.entry != nil && cell.entry!.habit!.isFake) {
      cell.swipable = true
    } else {
      cell.swipable = false
      let button = UIButton(type: .System)
      button.setTitle("Can't swipe " + (indexPath.section == 1 ? "upcoming" : "paused"), forState: .Normal)
      button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 16)!
      button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      button.backgroundColor = UIColor.darkGrayColor()
      button.sizeToFit()
      button.roundify(4)
      cell.cantSwipeLabel = button
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return HabitManager.currentCount
    case 1:
      return HabitManager.upcomingCount
    case 2:
      return HabitManager.pausedCount
    default:
      return 0
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // dispatch_async is needed here since selection happens in a new thread
    dispatch_async(dispatch_get_main_queue()) {
      let cell = tableView.cellForRowAtIndexPath(indexPath) as! HabitTableViewCell
      let shvc = self.storyboard!.instantiateViewControllerWithIdentifier("ShowHabitViewController") as! ShowHabitViewController
      shvc.modalPresentationStyle = .OverCurrentContext
      shvc.transitioningDelegate = self.showHabitTransition
      if let entry = cell.entry {
        shvc.habit = entry.habit!
      } else {
        shvc.habit = cell.habit!
      }
      self.presentViewController(shvc, animated: true, completion: nil)
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return HabitApp.TableCellHeight
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if HabitApp.upcoming {
      return 2 + (HabitManager.pausedCount > 0 ? 1 : 0)
      ///return 1 + (HabitManager.upcomingCount > 0 ? 1 : 0) + (HabitManager.pausedCount > 0 ? 1 : 0)
    } else {
      return 1
    }
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return ((section == 1 && HabitManager.upcomingCount > 0) || (section == 2 && HabitManager.pausedCount > 0)) ? HabitApp.TableSectionHeight : 0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    var headerId = "CURRENT"
    switch section {
    case 1:
      headerId = "UPCOMING"
    case 2:
      headerId = "PAUSED"
    default: ()
    }
    
    var header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId)
    if header == nil {
      header = UITableViewHeaderFooterView(reuseIdentifier: headerId)
      header!.frame = CGRectMake(0, 0, tableView.frame.width, 20)
      let title = UILabel()
      title.font = FontManager.regular(14)
      title.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
      title.text = headerId
      header!.contentView.addSubview(title)
      title.snp_makeConstraints { make in
        make.centerY.equalTo(header!.contentView).offset(1)
        make.left.equalTo(header!.contentView).offset(8)
      }
    }
    header!.contentView.backgroundColor = HabitApp.color
    return header
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
    statusBar!.backgroundColor = color
    newButton.backgroundColor = color
    tableView.reloadData()
    
    // Animate color change
    UIView.animateWithDuration(HabitApp.ColorChangeAnimationDuration,
      delay: 0,
      options: .CurveEaseInOut,
      animations: {
        self.overlayView.alpha = 0
      }, completion: { finished in
        imageView.removeFromSuperview()
    })
  }
  
  @IBAction func changeColorLeft(sender: AnyObject) {
    let newIndex = HabitApp.colorIndex - 1
    if newIndex == -1 {
      HabitApp.colorIndex = HabitApp.colors.count - 1
    } else {
      HabitApp.colorIndex = newIndex
    }
    changeColor(HabitApp.color)
  }

  @IBAction func changeColorRight(sender: AnyObject) {
    let newIndex = HabitApp.colorIndex + 1
    if newIndex == HabitApp.colors.count {
      HabitApp.colorIndex = 0
    } else {
      HabitApp.colorIndex = newIndex
    }
    changeColor(HabitApp.color)
  }
  
  // UIScrollView
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
//    NSLog("\(scrollView.contentOffset)")
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
      self.newButton.alpha = 0
    })
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
        self.newButton.alpha = 1
      })
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
      self.newButton.alpha = 1
    })
  }
  
  // SwipeTableViewCell
  
  func startSwiping(cell: SwipeTableViewCell) {
    UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
      self.newButton.alpha = 0
    })
  }
  
  func endSwiping(cell: SwipeTableViewCell) {
    if presentedViewController == nil {
      UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
        self.newButton.alpha = 1
      })
    }
  }
  
}

