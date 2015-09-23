//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

// TODO
//  1. Check timezone changes on load
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
// 14. Clean up AppDelegate
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
// 35: Start app first time with example habit
// 36: done - Pause habit
// 37: Launch screen
// 38: done - Resist swiping upcoming
// 39: done - Show frequency words after 1 second timeout
// 40: done - Fix overlay on frequency selection
// 41: done - Add touch listener to overlay view on MVC
// 42: done - Update pods to xcode 7
// 43: done - Debug hide keyboard in new habit
// 44: done - Fix border in habit history

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
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var newButton: UIButton!
  @IBOutlet weak var transitionOverlay: UIView!
  
  var statusBar: UIView?
  var activeCell: HabitTableViewCell?
  var entries = [Entry]()
  var upcoming = [Entry]()
  var refreshTimer: NSTimer?
  var appSettingsTransition: UIViewControllerTransitioningDelegate?
  var selectFrequencyTransition: UIViewControllerTransitioningDelegate?
  var showHabitTransition: UIViewControllerTransitioningDelegate?
  
  @IBAction func fill(sender: AnyObject) {
    do {
      let calendar = HabitApp.calendar
      var date = calendar.dateByAddingUnit(.WeekOfYear, value: -40, toDate: NSDate())!
      var h = Habit(context: HabitApp.moContext, name: "5. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: date)
      h.update(NSDate())
      while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
        //print(formatter.stringFromDate(date))
        let entries = h.entriesOnDate(date)
        //print("c: \(entries.count)")
        for i in 0..<Int(arc4random_uniform(UInt32(entries.count))) {
          entries[i].complete()
        }
        for entry in entries {
          if entry.state == .Todo {
            entry.skip()
          }
        }
        date = NSDate(timeInterval: 24 * 3600 * 7, sinceDate: date)
      }
      date = calendar.dateByAddingUnit(.WeekOfYear, value: -2, toDate: NSDate())!
      h = Habit(context: HabitApp.moContext, name: "W: Will not show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
      h.update(NSDate())
      date = calendar.dateByAddingUnit(.WeekOfYear, value: -5, toDate: NSDate())!
      h = Habit(context: HabitApp.moContext, name: "W: Will show skip dialog", details: "", frequency: .Weekly, times: 0, createdAt: date)
      h.daysOfWeek = [.Monday, .Tuesday, .Wednesday, .Friday, .Saturday]
      date = calendar.dateByAddingUnit(.WeekOfYear, value: 1, toDate: date)!
      h.update(date)
      h.deleteEntries(after: date)
      HabitApp.moContext.refreshAllObjects()
      h.pausedBool = true
      date = calendar.dateByAddingUnit(.WeekOfYear, value: 2, toDate: date)!
      h.update(date)
      h.pausedBool = false
      h.generateEntries(after: date)
      h.update(NSDate())
      date = calendar.dateByAddingUnit(.Day, value: -180, toDate: NSDate())!
      h = Habit(context: HabitApp.moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12, createdAt: date)
      h.update(NSDate())
      while !calendar.isDateInToday(date) {
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
      
      date = calendar.dateByAddingUnit(.Day, value: -25, toDate: NSDate())!
      h = Habit(context: HabitApp.moContext, name: "Daily with pause", details: "", frequency: .Daily, times: 12, createdAt: date)
      date = calendar.dateByAddingUnit(.Day, value: 4, toDate: date)!
      h.update(date)
      h.deleteEntries(after: date)
      HabitApp.moContext.refreshAllObjects()
      h.pausedBool = true
      date = calendar.dateByAddingUnit(.Day, value: 7, toDate: date)!
      h.update(date)
      h.pausedBool = false
      h.generateEntries(after: date)
      h.update(NSDate())

      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    reloadEntries()
    tableView.reloadData()
    refreshNotifications()
  }
  
  @IBAction func deleteAll(sender: AnyObject) {
    do {
      let habitRequest = NSFetchRequest(entityName: "Habit")
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: habitRequest)
      try HabitApp.moContext.executeRequest(deleteRequest)
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    reloadEntries()
    tableView.reloadData()
    UIApplication.sharedApplication().cancelAllLocalNotifications()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    appSettingsTransition = AppSettingsTransition()
    selectFrequencyTransition = SelectFrequencyTransition()
    showHabitTransition = ShowHabitTransition()
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    statusBar!.backgroundColor = HabitApp.color
    view.addSubview(statusBar!)
    
    // TODO: What's up with the "window!!"?
    UIApplication.sharedApplication().delegate!.window!!.tintColor = HabitApp.color
    
    do {
      let now = NSDate()
      let habitRequest = NSFetchRequest(entityName: "Habit")
      let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
      for habit in habits {
        habit.update(now)
        if HabitApp.autoSkip && !habit.neverAutoSkipBool {
          habit.skip(before: NSDate(timeInterval: HabitApp.autoSkipDelayTimeInterval, sinceDate: now))
        }
      }
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
    reloadEntries()
      
    // Setup timers
    //refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5 * 60, target: tableView, selector: "reloadData", userInfo: nil, repeats: true)
    
    // Setup colors
    tableView.backgroundView = nil
    tableView.backgroundColor = UIColor.darkGrayColor()
    // TODO: This separatorStyle was added when I switched to Xcode 7 beta 4. Probably a IB bug.
    tableView.separatorStyle = .None
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
  
  func removeHabit(habit: Habit) {
    tableView.beginUpdates()
    var removes: [NSIndexPath] = []
    for (index, entry) in entries.enumerate() {
      if entry.habit! == habit {
        removes.append(NSIndexPath(forItem: index, inSection: 0))
      }
    }
    entries = entries.filter { $0.habit! != habit }
    for (index, entry) in upcoming.enumerate() {
      if entry.habit! == habit {
        removes.append(NSIndexPath(forItem: index, inSection: 1))
      }
    }
    upcoming = upcoming.filter { $0.habit! != habit }
    if HabitApp.upcoming && upcoming.count == 0 {
      tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Top)
    }
    tableView.deleteRowsAtIndexPaths(removes, withRowAnimation: .Top)
    tableView.endUpdates()
  }
  
  func insertEntries(newEntries: [Entry]) {
    let upcomingCount = upcoming.count
    tableView.beginUpdates()
    reloadEntries()
    var inserts: [NSIndexPath] = []
    for (index, entry) in entries.enumerate() {
      if newEntries.contains(entry) {
        inserts.append(NSIndexPath(forItem: index, inSection: 0))
      }
    }
    for (index, entry) in upcoming.enumerate() {
      if newEntries.contains(entry) {
        inserts.append(NSIndexPath(forItem: index, inSection: 1))
      }
    }
    if HabitApp.upcoming && upcomingCount == 0 && upcoming.count > 0 {
      tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Top)
    }
    tableView.insertRowsAtIndexPaths(inserts, withRowAnimation: .Top)
    tableView.endUpdates()
  }
  
  func removeEntries(oldEntries: [Entry]) {
    var removes: [NSIndexPath] = []
    for (index, entry) in entries.enumerate() {
      if oldEntries.contains(entry) {
        removes.append(NSIndexPath(forItem: index, inSection: 0))
      }
    }
    for (index, entry) in upcoming.enumerate() {
      if oldEntries.contains(entry) {
        removes.append(NSIndexPath(forItem: index, inSection: 1))
      }
    }
    tableView.beginUpdates()
    reloadEntries()
    if HabitApp.upcoming && upcoming.count == 0 {
      tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Top)
    }
    tableView.deleteRowsAtIndexPaths(removes, withRowAnimation: .Top)
    tableView.endUpdates()
  }
  
  func reloadEntries() {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      request.predicate = NSPredicate(format: "stateRaw == %@ AND (due <= %@ || (due > %@ AND period IN %@))",
        Entry.State.Todo.rawValue, NSDate(), NSDate(), HabitApp.currentPeriods)
      entries = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      if HabitApp.upcoming {
        let request = NSFetchRequest(entityName: "Entry")
        request.predicate = NSPredicate(format: "stateRaw == %@ AND due > %@ AND NOT (period IN %@)",
          Entry.State.Todo.rawValue, NSDate(), HabitApp.currentPeriods)
        upcoming = (try HabitApp.moContext.executeFetchRequest(request) as! [Entry]).sort({ $0.dueIn < $1.dueIn })
      } else {
        upcoming = []
      }
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
    UIApplication.sharedApplication().applicationIconBadgeNumber = HabitApp.overdueCount
  }
  
  func refreshNotifications() {
    UIApplication.sharedApplication().cancelAllLocalNotifications()
    var count = 0
    var number = 1
    let now = NSDate()
    for entry in entries {
      if count > 64 {
        break
      }
      if entry.habit!.notifyBool && entry.due!.compare(now) == .OrderedDescending {
        HabitApp.addNotification(entry, number: number)
        count += 1
      }
      number += 1
    }
  }
  
  
  func hideCellAnimate(view: UIView, delay: NSTimeInterval, complete: (() -> Void)?) {
    var endFrame = view.frame
    endFrame.origin.y = view.frame.origin.y + self.tableView.superview!.bounds.height
    UIView.animateWithDuration(SlideAnimationDuration,
      delay: delay,
      options: [.CurveEaseIn],
      animations: {
        view.frame = endFrame
      }, completion: { finished in
        if complete != nil {
          complete!()
        }
      })
  }
  
  func hideUpcoming() -> Double {
    var delayStart = 0.0
    if upcoming.count > 0 {
      if let header = tableView.headerViewForSection(1) {
        for index in (0..<upcoming.count).reverse() {
          let indexPath = NSIndexPath(forRow: index, inSection: 1)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            hideCellAnimate(cell, delay: delayStart, complete: nil)
            delayStart += SlideAnimationDelay
          }
        }
        delayStart -= SlideAnimationDelay
        hideCellAnimate(header, delay: delayStart) {
          // Remove any traces of the old cells
          // Is this better than calling deleteRowsAtIndexPaths?
          self.upcoming = []
          self.tableView.reloadData()
        }
      } else {
        // If not visible, no animation
        upcoming = []
        tableView.reloadData()
      }
      delayStart += SlideAnimationDelay
    }
    return delayStart
  }
  
  
  func showCellAnimate(view: UIView, endFrame: CGRect, delay: NSTimeInterval) {
    var startFrame = view.frame
    startFrame.origin.y = endFrame.origin.y + self.tableView.superview!.bounds.height
    view.frame = startFrame
    UIView.animateWithDuration(SlideAnimationDuration,
      delay: delay,
      options: [.CurveEaseOut],
      animations: {
        view.frame = endFrame
      }, completion: nil)
  }
  
  func showUpcoming() {
    if upcoming.count > 0 {
      // Load up the cells to animate
      tableView.beginUpdates()
      tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .None)
      let indexPaths = upcoming.enumerate().map { (index, entry) in
        return NSIndexPath(forRow: index, inSection: 1)
      }
      tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
      tableView.endUpdates()
      
      var delayStart: Double = 0
      if let header = tableView.headerViewForSection(1) {
        showCellAnimate(header, endFrame: tableView.rectForHeaderInSection(1), delay: delayStart)
        for (index, _) in upcoming.enumerate() {
          let indexPath = NSIndexPath(forRow: index, inSection: 1)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            showCellAnimate(cell, endFrame: tableView.rectForRowAtIndexPath(indexPath), delay: delayStart)
            delayStart += SlideAnimationDelay
          }
        }
      }
    }
  }
  
  func resetFuture() {
    var cellsToHide: [UIView] = []
    if HabitApp.upcoming {
      if let header = tableView.headerViewForSection(1) {
        for index in (0..<upcoming.count).reverse() {
          let indexPath = NSIndexPath(forRow: index, inSection: 1)
          if tableView.indexPathsForVisibleRows!.contains(indexPath) {
            cellsToHide.append(tableView.cellForRowAtIndexPath(indexPath)!)
          }
        }
        cellsToHide.append(header)
      }
    }
    var entriesToDelete: [Entry] = []
    let future = HabitApp.calendar.zeroTime(HabitApp.calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate())!)
    for (index, entry) in entries.enumerate() {
      if future.compare(entry.due!) == .OrderedAscending {
        for i in (index..<entries.count).reverse() {
          entriesToDelete.append(entries[i])
          let indexPath = NSIndexPath(forRow: i, inSection: 0)
          if tableView.indexPathsForVisibleRows!.contains(indexPath) {
            cellsToHide.append(tableView.cellForRowAtIndexPath(indexPath)!)
          }
        }
        break
      }
    }
    var delayStart = 0.0
    for index in 0..<cellsToHide.count {
      if let _ = cellsToHide[index] as? UITableViewHeaderFooterView {
        delayStart -= SlideAnimationDelay
      }
      if index != cellsToHide.count - 1 {
        hideCellAnimate(cellsToHide[index], delay: delayStart, complete: nil)
      } else {
        hideCellAnimate(cellsToHide[index], delay: delayStart) {
          self.reloadEntries()
          
          var cellsToShow: [(UIView, CGRect)] = []
          for (index, entry) in self.entries.enumerate() {
            if future.compare(entry.due!) == .OrderedAscending {
              for i in index..<self.entries.count {
                let indexPath = NSIndexPath(forRow: i, inSection: 0)
                if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                  cellsToShow.append((self.tableView.cellForRowAtIndexPath(indexPath)!,
                                      self.tableView.rectForRowAtIndexPath(indexPath)))
                }
              }
              break
            }
          }
          if HabitApp.upcoming {
            // Header will be returned if visible
            cellsToShow.append((self.tableView.headerViewForSection(1)!,
                                self.tableView.rectForHeaderInSection(1)))
            for index in 0..<self.upcoming.count {
              let indexPath = NSIndexPath(forRow: index, inSection: 1)
              if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cellsToShow.append((self.tableView.cellForRowAtIndexPath(indexPath)!,
                                    self.tableView.rectForRowAtIndexPath(indexPath)))
              }
            }
          }
          var delayStart = 0.0
          for cellTuple in cellsToShow {
            if let _ = cellTuple.0 as? UITableViewHeaderFooterView {
              delayStart -= self.SlideAnimationDelay
            }
            self.showCellAnimate(cellTuple.0, endFrame: cellTuple.1, delay: delayStart)
            delayStart += self.SlideAnimationDelay
          }
        }
      }
      delayStart += SlideAnimationDelay
    }
    do {
      // Do batch delete from ios9
      for entry in entriesToDelete {
        HabitApp.moContext.deleteObject(entry)
      }
      for entry in upcoming {
        HabitApp.moContext.deleteObject(entry)
      }
      let habitRequest = NSFetchRequest(entityName: "Habit")
      let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
      for habit in habits {
        habit.update(NSDate())
      }
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
  }
  
  // Table view
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let removeEntry = { (indexPath: NSIndexPath, skip: Bool) in
      let entry = indexPath.section == 0 ? self.entries.removeAtIndex(indexPath.row) : self.upcoming.removeAtIndex(indexPath.row)
      if (skip) {
        entry.skip()
      } else {
        entry.complete()
      }
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
    }
    
    let completion = { (cell: SwipeTableViewCell, skipped skipped: Bool) in
      let indexPath = tableView.indexPathForCell(cell)!
      if skipped {
        var skipOne = true
        let entry = indexPath.section == 0 ? self.entries[indexPath.row] : self.upcoming[indexPath.row]
        switch entry.habit!.frequency {
        case .Daily:
          skipOne = HabitApp.calendar.components([.Day], fromDate: entry.habit!.firstTodo!.due!, toDate: NSDate()).day <= 2
        case .Weekly:
          skipOne = HabitApp.calendar.components([.Day], fromDate: entry.habit!.firstTodo!.due!, toDate: NSDate()).day <= 14
        case .Monthly:
          skipOne = HabitApp.calendar.components([.Month], fromDate: entry.habit!.firstTodo!.due!, toDate: NSDate()).month <= 2
        default: ()
        }
        if skipOne {
          removeEntry(indexPath, true)
          UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
            self.newButton.alpha = 1
          })
        } else {
          let sdvc = self.storyboard!.instantiateViewControllerWithIdentifier("SwipeDialogViewController") as! SwipeDialogViewController
          sdvc.modalTransitionStyle = .CrossDissolve
          sdvc.modalPresentationStyle = .OverCurrentContext
          sdvc.yesCompletion = {
            var indexPaths: [NSIndexPath] = []
            if entry.due!.compare(NSDate()) == .OrderedDescending {
              entry.skip()
              indexPaths.append(indexPath)
            }
            let skippedEntries = entry.habit!.skip(before: NSDate(timeIntervalSinceNow: HabitApp.autoSkipDelayTimeInterval))
            for e in skippedEntries {
              indexPaths.append(NSIndexPath(forRow: self.entries.indexOf(e)!, inSection: 0))
            }
            self.reloadEntries()
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
            self.dismissViewControllerAnimated(true, completion: {
              UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
                self.newButton.alpha = 1
              })
            })
          }
          sdvc.noCompletion = {
            removeEntry(indexPath, true)
            self.dismissViewControllerAnimated(true, completion: {
              UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
                self.newButton.alpha = 1
              })
            })
          }
          self.presentViewController(sdvc, animated: true, completion: nil)
        }
      } else {
        removeEntry(indexPath, false)
        UIView.animateWithDuration(HabitApp.NewButtonFadeAnimationDuration, animations: {
          self.newButton.alpha = 1
        })
      }
      do {
        try HabitApp.moContext.save()
      } catch let error {
        NSLog("Error saving: \(error)")
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    let entry = indexPath.section == 0 ? entries[indexPath.row] : upcoming[indexPath.row]
    cell.load(entry)
    cell.delegate = self
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.Check, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: HabitApp.green,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        completion(cell, skipped: false)
    })
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.History, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: HabitApp.yellow,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        completion(cell, skipped: true)
    })
    if indexPath.section == 1 {
      cell.swipable = false
      let button = UIButton(type: .System)
      button.setTitle("Can't swipe upcoming", forState: .Normal)
      button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 16)!
      button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      button.backgroundColor = UIColor.darkGrayColor()
      button.sizeToFit()
      button.roundify(4)
      cell.cantSwipeLabel = button
    } else {
      cell.swipable = true
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? entries.count : upcoming.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TODO: need dispatch?
    dispatch_async(dispatch_get_main_queue()) {
      self.activeCell = tableView.cellForRowAtIndexPath(indexPath) as? HabitTableViewCell
      let shvc = self.storyboard!.instantiateViewControllerWithIdentifier("ShowHabitViewController") as! ShowHabitViewController
      shvc.modalPresentationStyle = .OverCurrentContext
      shvc.transitioningDelegate = self.showHabitTransition
      shvc.habit = self.activeCell!.entry!.habit!
      self.presentViewController(shvc, animated: true, completion: nil)
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return upcoming.isEmpty ? 1 : 2
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return (section == 1 && upcoming.count > 0) ? 18 : 0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let upcomingHeader = "UPCOMING_HEADER"
    
    var header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(upcomingHeader)
    if header == nil {
      header = UITableViewHeaderFooterView(reuseIdentifier: upcomingHeader)
    }
    header!.frame = CGRectMake(0, 0, tableView.frame.width, 20)
    header!.contentView.backgroundColor = HabitApp.color
    let title = UILabel()
    title.font = UIFont(name: "Bariol-Regular", size: 14.0)!
    title.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
    title.text = section == 0 ? "CURRENT" : "UPCOMING"
    header!.contentView.addSubview(title)
    title.snp_makeConstraints { make in
      make.centerY.equalTo(header!.contentView).offset(1)
      make.left.equalTo(header!.contentView).offset(8)
    }
    return header
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    
    if segue.destinationViewController is AppSettingsViewController {
      segue.destinationViewController.transitioningDelegate = appSettingsTransition
      segue.destinationViewController.modalPresentationStyle = .Custom
    } else if segue.destinationViewController is SelectFrequencyViewController {
      segue.destinationViewController.transitioningDelegate = selectFrequencyTransition
      segue.destinationViewController.modalPresentationStyle = .Custom
    }
  }
  
  @IBAction func unwind(segue: UIStoryboardSegue) { }
  
  // Colors
  
  func changeColor(color: UIColor) {
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
    UIApplication.sharedApplication().keyWindow!.tintColor = color
    titleBar.backgroundColor = color
    statusBar!.backgroundColor = color
    newButton.backgroundColor = color
    tableView.reloadData()
    
    // Animate color change
    UIView.animateWithDuration(0.5,
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

