//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

// TODO
// 1. Check timezone changes on load
// 2. Snooze behavior
// 3. Sort habits based on time periods
// 4. github style history graph
// 5. Habit info page
// 6. App settings
// 7. Local notifications

import UIKit
import CoreData
import FontAwesome_swift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // App colors
  static let green = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
  static let yellow = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
  
  // User color options
  static let blueTint = UIColor(red: 42.0 / 255.0, green: 132.0 / 255.0, blue: 219.0 / 255.0, alpha: 1)
  static let purpleTint = UIColor(red: 155.0 / 255.0, green: 79.0 / 255.0, blue: 172.0 / 255.0, alpha: 1)
  static let greenTint = UIColor(red: 46.0 / 255.0, green: 180.0 / 255.0, blue: 113.0 / 255.0, alpha: 1)
  static let darkBlueTint = UIColor(red: 52.0 / 255.0, green: 73.0 / 255.0, blue: 120.0 / 255.0, alpha: 1)
  static let greyTint = UIColor(red: 130.0 / 255.0, green: 130.0 / 255.0, blue: 130.0 / 255.0, alpha: 1)
  static let orangeTint = UIColor(red: 230.0 / 255.0, green: 146.0 / 255.0, blue: 45.0 / 255.0, alpha: 1)
  static let colors = [blueTint, purpleTint, greenTint, darkBlueTint, greyTint, orangeTint]
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    statusBar = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
    view.addSubview(statusBar!)
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
    statusBar!.backgroundColor = MainViewController.colors[1]
    // TODO: What's up with the "window!!"?
    UIApplication.sharedApplication().delegate!.window!!.tintColor = MainViewController.colors[1]
    
    let requestAny = NSFetchRequest(entityName: "Habit")
    do {
      habits = try moContext.executeFetchRequest(requestAny) as! [Habit]
      if habits.count == 0 {
        Habit.create(moc: moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12)
        Habit.create(moc: moContext, name: "4. Daily 8x", details: "", frequency: .Daily, times: 8)
        Habit.create(moc: moContext, name: "5. Daily 4x", details: "", frequency: .Daily, times: 4)
        Habit.create(moc: moContext, name: "6. Daily 1x", details: "", frequency: .Daily, times: 1)
        Habit.create(moc: moContext, name: "7. Weekly 6x", details: "", frequency: .Weekly, times: 6)
        Habit.create(moc: moContext, name: "8. Weekly 3x", details: "", frequency: .Weekly, times: 3)
        Habit.create(moc: moContext, name: "9. Weekly 1x", details: "", frequency: .Weekly, times: 1)
        Habit.create(moc: moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12)
        Habit.create(moc: moContext, name: "4. Daily 8x", details: "", frequency: .Daily, times: 8)
        Habit.create(moc: moContext, name: "5. Daily 4x", details: "", frequency: .Daily, times: 4)
        Habit.create(moc: moContext, name: "6. Daily 1x", details: "", frequency: .Daily, times: 1)
        Habit.create(moc: moContext, name: "7. Weekly 6x", details: "", frequency: .Weekly, times: 6)
        Habit.create(moc: moContext, name: "8. Weekly 3x", details: "", frequency: .Weekly, times: 3)
        Habit.create(moc: moContext, name: "9. Weekly 1x", details: "", frequency: .Weekly, times: 1)
        Habit.create(moc: moContext, name: "1. Daily 12x", details: "", frequency: .Daily, times: 12)
        Habit.create(moc: moContext, name: "4. Daily 8x", details: "", frequency: .Daily, times: 8)
        Habit.create(moc: moContext, name: "5. Daily 4x", details: "", frequency: .Daily, times: 4)
        Habit.create(moc: moContext, name: "6. Daily 1x", details: "", frequency: .Daily, times: 1)
        Habit.create(moc: moContext, name: "7. Weekly 6x", details: "", frequency: .Weekly, times: 6)
        Habit.create(moc: moContext, name: "8. Weekly 3x", details: "", frequency: .Weekly, times: 3)
        Habit.create(moc: moContext, name: "9. Weekly 1x", details: "", frequency: .Weekly, times: 1)
        try self.moContext.save()
      }
    } catch let error as NSError {
      NSLog("Could not save \(error), \(error.userInfo)")
    } catch {
      NSLog("Could not save")
    }
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      habits = try moContext.executeFetchRequest(request) as! [Habit]
      habits = habits.sort({ $0.dueIn < $1.dueIn })
    } catch let error as NSError {
      NSLog("Fetch failed: \(error.localizedDescription)")
    }
    
    tableView.backgroundView = nil
    tableView.backgroundColor = UIColor.darkGrayColor()
    titleBar.backgroundColor = UIApplication.sharedApplication().windows[0].tintColor
    
    newButton.backgroundColor = UIApplication.sharedApplication().windows[0].tintColor
    newButton.layer.cornerRadius = 28
    newButton.layer.shadowOpacity = 0.5
    newButton.layer.shadowRadius = 2
    newButton.layer.shadowOffset = CGSizeMake(0, 1)
    
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
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let completion = { (cell: SwipeTableViewCell) -> Void in
      // TODO: Remove updates and delay insert
      tableView.beginUpdates()
      let indexPath = tableView.indexPathForCell(cell)!
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
      let habit = self.habits.removeAtIndex(indexPath.row)
      tableView.endUpdates()
      
      let entry = Entry.create(moc: self.moContext, habit: habit)
      habit.last = entry.createdAt!
      do {
        try self.moContext.save()
      } catch let error as NSError {
        NSLog("Could not save \(error), \(error.userInfo)")
      } catch {
        NSLog("Could not save")
      }
      
      self.insertHabit(habit)
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    cell.load(habits[indexPath.row])
    
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage(named: "Checkmark")),
      color: MainViewController.green,
      options: [.Rotate, .Alpha],
      completion: completion)
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage(named: "Clock")),
      color: MainViewController.yellow,
      options: [.Rotate, .Alpha],
      completion: completion)
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let vc = segue.destinationViewController as! HabitViewController
    if segue.identifier == showHabitSegue {
      activeCell = sender as? HabitTableViewCell
      vc.habit = activeCell!.habit
    } else {
      vc.habit = Habit.create(moc: moContext, name: "", details: "", frequency: .Daily, times: 1)
      
      newButton.highlighted = false
    }
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
    view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
    vc.blurImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    UIApplication.sharedApplication().keyWindow!.windowLevel = UIWindowLevelStatusBar + 1
  }
  
  @IBAction func unwind(segue: UIStoryboardSegue) {
    UIApplication.sharedApplication().keyWindow!.windowLevel = UIWindowLevelNormal
    
    let vc = segue.sourceViewController as! HabitViewController;
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
    var currentColorIndex = MainViewController.colors.indexOf(titleBar.backgroundColor!)! - 1
    if currentColorIndex == 0 {
      currentColorIndex = MainViewController.colors.count - 1
    }
    changeColor(MainViewController.colors[currentColorIndex])
  }

  @IBAction func changeColorRight(sender: AnyObject) {
    var currentColorIndex = MainViewController.colors.indexOf(titleBar.backgroundColor!)! + 1
    if currentColorIndex == MainViewController.colors.count {
      currentColorIndex = 0
    }
    changeColor(MainViewController.colors[currentColorIndex])
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

