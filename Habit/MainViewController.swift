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
// 4. github style history graph
// 5. 25% - Habit info page
// 6. done - App settings
// 7. Local notifications
// 8. done - Expire habits periodically

import UIKit
import CoreData
import FontAwesome_swift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // IB identifiers
  let cellIdentifier = "HabitCell"
  let newHabitSegue = "NewHabit"
  let showHabitSegue = "ShowHabit"

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleBar: UIView!
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var newButton: UIButton!
  
  var statusBar: UIView?
  var activeCell: HabitTableViewCell?
  var habits = [Habit]()
  var todaysHabits = [Habit]()
  var upcomingHabits = [Habit]()
  var refreshTimer: NSTimer?
  var settingsTransition: SettingsTransition?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    settingsTransition = SettingsTransition()
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    view.addSubview(statusBar!)
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
    statusBar!.backgroundColor = HabitApp.color
    // TODO: What's up with the "window!!"?
    UIApplication.sharedApplication().delegate!.window!!.tintColor = HabitApp.color
    
    let requestAny = NSFetchRequest(entityName: "Habit")
    do {
      if #available(iOS 9.0, *) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: requestAny)
        try HabitApp.moContext.executeRequest(deleteRequest)
      } else {
          // Fallback on earlier versions
      }
      
      habits = try HabitApp.moContext.executeFetchRequest(requestAny) as! [Habit]
      if habits.count == 0 {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: NSDate())
        components.month -= 5
        components.hour = 1
        var date = calendar.dateFromComponents(components)!
        let h = Habit(context: HabitApp.moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12)
        h.createdAt = date
        h.last = date
        while !calendar.isDateInToday(date) {
          for _ in 0..<Int(arc4random_uniform(12)) {
            h.addEntry(onDate: date)
          }
          date = NSDate(timeInterval: 24 * 3600, sinceDate: date)
          h.updateNext(date)
        }
//        h = Habit(context: HabitApp.moContext, name: "2. Daily 8x", details: "", frequency: .Daily, times: 8)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "3. Daily 4x", details: "", frequency: .Daily, times: 4)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "4. Daily 1x", details: "", frequency: .Daily, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "5. Weekly 6x", details: "", frequency: .Weekly, times: 6)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "6. Weekly 3x", details: "", frequency: .Weekly, times: 3)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "7. Weekly 1x", details: "", frequency: .Weekly, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "8. Daily 12x", details: "", frequency: .Daily, times: 12)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "9. Daily 8x", details: "", frequency: .Daily, times: 8)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "10. Daily 4x", details: "", frequency: .Daily, times: 4)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "11. Daily 1x", details: "", frequency: .Daily, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "12. Weekly 6x", details: "", frequency: .Weekly, times: 6)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "13. Weekly 3x", details: "", frequency: .Weekly, times: 3)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "14. Weekly 1x", details: "", frequency: .Weekly, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "15. Daily 12x", details: "", frequency: .Daily, times: 12)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "16. Daily 8x", details: "", frequency: .Daily, times: 8)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "17. Daily 4x", details: "", frequency: .Daily, times: 4)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "18. Daily 1x", details: "", frequency: .Daily, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "19. Weekly 6x", details: "", frequency: .Weekly, times: 6)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "20. Weekly 3x", details: "", frequency: .Weekly, times: 3)
//        h.createdAt = createdAt
//        h.last = createdAt
//        h = Habit(context: HabitApp.moContext, name: "21. Weekly 1x", details: "", frequency: .Weekly, times: 1)
//        h.createdAt = createdAt
//        h.last = createdAt
        try HabitApp.moContext.save()
      }
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      habits = try HabitApp.moContext.executeFetchRequest(request) as! [Habit]
      for habit in habits {
        habit.updateNext(NSDate())
      }
      habits = habits.sort({ $0.dueIn < $1.dueIn })
      try HabitApp.moContext.save()
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
    
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
    refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5 * 60, target: self, selector: "refreshTableView", userInfo: nil, repeats: true)
    
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
  
  // Table view
  
  func refreshTableView() {
    if !SwipeTableViewCell.isSwiping {
      for habit in habits {
        habit.updateNext(NSDate())
      }
      do {
        try HabitApp.moContext.save()
      } catch let error as NSError {
        NSLog("Error saving: \(error.localizedDescription)")
      }
      habits = habits.sort({ $0.dueIn < $1.dueIn })
      tableView.reloadData()
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let completion = { (cell: SwipeTableViewCell, skipped skipped: Bool) -> Void in
      // TODO: Remove updates and delay insert
      tableView.beginUpdates()
      let indexPath = tableView.indexPathForCell(cell)!
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
      let habit = self.habits.removeAtIndex(indexPath.row)
      tableView.endUpdates()
      
      habit.addEntry(onDate: NSDate())
      do {
        try HabitApp.moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      } catch {
        NSLog("Could not save")
      }
      
      habit.updateNext(NSDate())
      do {
        try HabitApp.moContext.save()
      } catch let error {
        NSLog("Error saving: \(error)")
      }
      self.insertHabit(habit)
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    cell.load(habits[indexPath.row])
    NSLog("cellFor: \(unsafeAddressOf(cell)) \(cell.habit!.name!)")
    
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
    return habits.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    dispatch_async(dispatch_get_main_queue()) {
      self.performSegueWithIdentifier(self.showHabitSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
  }
  
  func insertHabit(habit: Habit) {
    let insert = { (habit: Habit, index: Int) -> Void in
      self.habits.insert(habit, atIndex: index)
      self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Fade)
    }
    
    if habits.count > 0 {
      for index in 0...habits.count {
        if index == habits.count || habit.dueIn < habits[index].dueIn {
          insert(habit, index)
          break
        }
      }
    } else {
      insert(habit, 0)
    }
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? HabitViewController {
      if segue.identifier == showHabitSegue {
        activeCell = sender as? HabitTableViewCell
        vc.habit = activeCell!.habit
      } else {
        vc.habit = Habit(context: HabitApp.moContext, name: "", details: "", frequency: .Daily, times: 1)
        
        newButton.highlighted = false
      }
    } else {
      super.prepareForSegue(segue, sender: sender)
      
      segue.destinationViewController.transitioningDelegate = settingsTransition
      segue.destinationViewController.modalPresentationStyle = .Custom
      
      (segue.destinationViewController as! SettingsViewController).mainVC = self
    }
  }
  
  @IBAction func unwind(segue: UIStoryboardSegue) {    
    if let vc = segue.sourceViewController as? HabitViewController {
      if activeCell == nil {
        if vc.habit != nil {
          insertHabit(vc.habit!)
        }
      } else {
        let indexPath = tableView.indexPathForCell(activeCell!)
        tableView.deselectRowAtIndexPath(indexPath!, animated: false)
        if vc.habit == nil {
          habits.removeAtIndex(indexPath!.row)
          tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
        } else {
          let habit = habits[indexPath!.row]
          habits = habits.sort({ $0.dueIn < $1.dueIn })
          let newIndex = habits.indexOf(habit)
          if indexPath!.row != newIndex {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: newIndex!, inSection: 0)], withRowAnimation: .Top)
            tableView.endUpdates()
          } else {
            (tableView.cellForRowAtIndexPath(indexPath!) as! HabitTableViewCell).reload()
          }
        }
        activeCell = nil
      }
    }
  }
  
  // Colors
  
  func changeColor(color: UIColor) {
    // Snapshot previous color
    let snapshotView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(true)
    overlayView.addSubview(snapshotView)
    overlayView.hidden = false
    overlayView.alpha = 1
    view.bringSubviewToFront(overlayView)

    // Change color
    UIApplication.sharedApplication().keyWindow!.tintColor = color
    titleBar.backgroundColor = color
    statusBar!.backgroundColor = color
    newButton.backgroundColor = color
    tableView.reloadData()
    UILabel.appearance().textColor = color
    
    // Animate color change
    UIView.animateWithDuration(0.5,
      delay: 0,
      options: .CurveEaseInOut,
      animations: {
        self.overlayView.alpha = 0
      }, completion: { (value: Bool) in
        self.overlayView.hidden = true
        for subview in self.overlayView.subviews {
          subview.removeFromSuperview()
        }
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
    NSLog("\(scrollView.contentOffset)")
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

