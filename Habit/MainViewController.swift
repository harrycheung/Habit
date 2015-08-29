//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

// TODO
// 1. Check timezone changes on load
// 2. done - Snooze behavior
// 3. done - Sort habits based on time periods
// 4. done - github style history graph
// 5. 75% - Habit info page
// 6. done - App settings
// 7. Local notifications
// 8. done - Expire habits periodically
// 9. done - Split HabitViewController
// 10. done - Use Entry for tableview
// 11. done - Debug flash when changing color
// 12. done - Debug flash when dismising habit settings
// 13. done - simulator only - Debug flash on color picker button
// 14. Clean up AppDelegate
// 15. Auto-skip
// 16. done - If a lot to be done, ask to skip all
// 17. Pretify show upcoming animation
// 18. Pretify insert new habit
// 19. Warn when changing habit frequency and handle
// 20. Skip icon

import UIKit
import CoreData
import FontAwesome_swift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // IB identifiers
  let cellIdentifier = "HabitCell"
  let showHabitSegue = "ShowHabit"

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var newButton: UIButton!
  
  var statusBar: UIView?
  var activeCell: HabitTableViewCell?
  var entries = [Entry]()
  var refreshTimer: NSTimer?
  var appSettingsTransition: AppSettingsTransition?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    appSettingsTransition = AppSettingsTransition()
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    view.addSubview(statusBar!)
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
    statusBar!.backgroundColor = HabitApp.color
    // TODO: What's up with the "window!!"?
    UIApplication.sharedApplication().delegate!.window!!.tintColor = HabitApp.color
    
    do {
      let habitRequest = NSFetchRequest(entityName: "Habit")
      if #available(iOS 9.0, *) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: habitRequest)
        try HabitApp.moContext.executeRequest(deleteRequest)
      } else {
        var habitsToDelete = try HabitApp.moContext.executeFetchRequest(habitRequest)
        for habit in habitsToDelete {
          HabitApp.moContext.deleteObject(habit as! NSManagedObject)
        }
        habitsToDelete.removeAll(keepCapacity: false)
        try HabitApp.moContext.save()
      }
      
      let formatter = NSDateFormatter();
      formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
      formatter.timeZone = NSTimeZone(abbreviation: "PST");
      let habits = try HabitApp.moContext.executeFetchRequest(habitRequest) as! [Habit]
      if habits.count == 0 {
        let calendar = NSCalendar.currentCalendar()
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
        h = Habit(context: HabitApp.moContext, name: "Will not show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
        h.update(NSDate())
        date = calendar.dateByAddingUnit(.WeekOfYear, value: -3, toDate: NSDate())!
        h = Habit(context: HabitApp.moContext, name: "Will show skip dialog", details: "", frequency: .Weekly, times: 6, createdAt: date)
        h.update(NSDate())
//        components = calendar.components([.Year, .Month, .Day, .Hour], fromDate: NSDate())
//        components.month -= 20
//        components.day = 3
//        components.hour = 1
//        date = calendar.dateFromComponents(components)!
//        h = Habit(context: HabitApp.moContext, name: "5. Monthly 4x", details: "", frequency: .Monthly, times: 4, createdAt: date)
//        while !calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Month) {
//          for _ in 0..<Int(arc4random_uniform(4)) {
//            h.addEntry(onDate: date)
//          }
//          components.month += 1
//          date = calendar.dateFromComponents(components)!
//          hupdate(date)
//        }
//        let oneDay = NSDateComponents()
//        oneDay.day = 1
//        components.month -= 8
//        date = calendar.dateFromComponents(components)!
//        h = Habit(context: HabitApp.moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12, createdAt: date)
//        while !calendar.isDateInToday(date) {
//          for _ in 0..<Int(arc4random_uniform(13)) {
//            h.addEntry(onDate: date)
//          }
//          date = calendar.dateByAddingComponents(oneDay, toDate: date)!
//          hupdate(date)
//        }
//        let createdAt = NSDate()
//        let _ = Habit(context: HabitApp.moContext, name: "2. Daily 8x", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "3. Daily 4x", details: "", frequency: .Daily, times: 4, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "4. Daily 1x", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "6. Weekly 3x", details: "", frequency: .Weekly, times: 3, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "7. Weekly 1x", details: "", frequency: .Weekly, times: 1, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "8. Daily 12x", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "9. Daily 8x", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "10. Daily 4x", details: "", frequency: .Daily, times: 4, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "11. Daily 1x", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "12. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "13. Weekly 3x", details: "", frequency: .Weekly, times: 3, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "14. Weekly 1x", details: "", frequency: .Weekly, times: 1, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "15. Daily 12x", details: "", frequency: .Daily, times: 12, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "16. Daily 8x", details: "", frequency: .Daily, times: 8, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "17. Daily 4x", details: "", frequency: .Daily, times: 4, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "18. Daily 1x", details: "", frequency: .Daily, times: 1, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "19. Weekly 6x", details: "", frequency: .Weekly, times: 6, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "20. Weekly 3x", details: "", frequency: .Weekly, times: 3, createdAt: createdAt)
//        let _ = Habit(context: HabitApp.moContext, name: "21. Weekly 1x", details: "", frequency: .Weekly, times: 1, createdAt: createdAt)
        try HabitApp.moContext.save()
      }
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    
    reloadEntries()
    
    // Setup colors
    tableView.backgroundView = nil
    tableView.backgroundColor = UIColor.darkGrayColor()
    // TODO: This separatorStyle was added when I switched to Xcode 7 beta 4. Probably a IB bug.
    tableView.separatorStyle = .None
    titleBar.backgroundColor = UIApplication.sharedApplication().windows[0].tintColor
    newButton.backgroundColor = UIApplication.sharedApplication().windows[0].tintColor
    newButton.layer.cornerRadius = 28
    newButton.layer.shadowColor = UIColor.blackColor().CGColor
    newButton.layer.shadowOpacity = 0.5
    newButton.layer.shadowRadius = 3
    newButton.layer.shadowOffset = CGSizeMake(0, 1)
    
    // Setup timers
    refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5 * 60, target: tableView, selector: "reloadData", userInfo: nil, repeats: true)
    
//    for family in UIFont.familyNames() {
//      NSLog("\(family)")
//      
//      for name in UIFont.fontNamesForFamilyName(family as! String) {
//        NSLog("  \(name)")
//      }
//    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func reloadEntries() {
    do {
      let request = NSFetchRequest(entityName: "Entry")
      var predicates = [NSPredicate(format: "stateRaw == %@", Entry.State.Todo.rawValue)]
      if !HabitApp.upcoming {
        let tonight = HabitApp.calendar.zeroTime(HabitApp.calendar.dateByAddingUnit(.Day, value: 1, toDate: NSDate())!)
        predicates.append(NSPredicate(format: "due <= %@", tonight))
      }
      request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
      let fetchedEntries = try HabitApp.moContext.executeFetchRequest(request) as! [Entry]
      let now = NSDate()
      for entry in fetchedEntries {
        entry.habit!.update(now)
      }
      try HabitApp.moContext.save()
      entries = fetchedEntries.sort({ $0.dueIn < $1.dueIn })
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
  }
  
  // Table view
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let removeEntry = { (indexPath: NSIndexPath, skip: Bool) in
      let entry = self.entries.removeAtIndex(indexPath.row)
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
        let entry = self.entries[indexPath.row]
        print(entry.habit!.firstTodo!.due!)
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
        } else {
          let sdvc = self.storyboard!.instantiateViewControllerWithIdentifier("SwipeDialogViewController") as! SwipeDialogViewController
          sdvc.modalTransitionStyle = .CrossDissolve
          sdvc.modalPresentationStyle = .OverCurrentContext
          sdvc.yesCompletion = { () in
            var indexPaths: [NSIndexPath] = []
            let skippedEntries = entry.habit!.skipBefore(NSDate())
            for e in skippedEntries {
              indexPaths.append(NSIndexPath(forRow: self.entries.indexOf(e)!, inSection: 0))
            }
            self.reloadEntries()
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
            self.dismissViewControllerAnimated(true, completion: nil)
          }
          sdvc.noCompletion = { () in
            removeEntry(indexPath, true)
            self.dismissViewControllerAnimated(true, completion: nil)
          }
          self.presentViewController(sdvc, animated: true, completion: nil)
        }
      } else {
        removeEntry(indexPath, false)
      }
      do {
        try HabitApp.moContext.save()
      } catch let error {
        NSLog("Error saving: \(error)")
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    cell.load(entries[indexPath.row])
    
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage(named: "Checkmark")),
      color: HabitApp.green,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        completion(cell, skipped: false)
    })
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage(named: "Clock")),
      color: HabitApp.yellow,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        completion(cell, skipped: true)
    })
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    dispatch_async(dispatch_get_main_queue()) {
      self.activeCell = tableView.cellForRowAtIndexPath(indexPath) as? HabitTableViewCell
      let hvc = self.storyboard!.instantiateViewControllerWithIdentifier("HabitViewController") as! HabitViewController
      hvc.modalTransitionStyle = .CrossDissolve
      hvc.modalPresentationStyle = .OverCurrentContext
      hvc.habit = self.activeCell!.entry!.habit!
      self.presentViewController(hvc, animated: true, completion: nil)
    }
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    if segue.destinationViewController is AppSettingsViewController {
      segue.destinationViewController.transitioningDelegate = appSettingsTransition
      segue.destinationViewController.modalPresentationStyle = .Custom
    } else if let vc = segue.destinationViewController as? HabitSettingsViewController {
      vc.habit = Habit(context: HabitApp.moContext, name: "", details: "", frequency: .Daily, times: 1, createdAt: NSDate())
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
      }, completion: { (value: Bool) in
        imageView.removeFromSuperview()
    })
  }
  
  @IBAction func changeColorLeft(sender: AnyObject) {
    var currentColorIndex = HabitApp.colors.indexOf(titleBar.backgroundColor!)! - 1
    if currentColorIndex == 0 {
      currentColorIndex = HabitApp.colors.count - 1
    }
    changeColor(HabitApp.colors[currentColorIndex])
    HabitApp.colorIndex = currentColorIndex
  }

  @IBAction func changeColorRight(sender: AnyObject) {
    var currentColorIndex = HabitApp.colors.indexOf(titleBar.backgroundColor!)! + 1
    if currentColorIndex == HabitApp.colors.count {
      currentColorIndex = 0
    }
    changeColor(HabitApp.colors[currentColorIndex])
    HabitApp.colorIndex = currentColorIndex
  }
  
  // UIScrollView
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
//    NSLog("\(scrollView.contentOffset)")
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    UIView.animateWithDuration(0.2, animations: {
      self.newButton.alpha = 0
    })
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      UIView.animateWithDuration(0.2, animations: {
        self.newButton.alpha = 1
      })
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    UIView.animateWithDuration(0.2, animations: {
      self.newButton.alpha = 1
    })
  }
  
}

