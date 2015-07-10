//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  static let blue = UIColor(red: 42.0 / 255.0, green: 132.0 / 255.0, blue: 219.0 / 255.0, alpha: 1)
  static let green = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
  static let yellow = UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1)
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  let cellIdentifier = "HabitCell"
  let showHabitSegue = "ShowHabit"
  let newHabitSegue = "NewHabit"

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var titleBar: UIView!
  
  var activeCell: HabitTableViewCell?
  var habits = [Habit]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor.blackColor()
    
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
      print("Fetch failed: \(error.localizedDescription)")
    }
    
    tableView.backgroundView = nil
    
//    UIApplication.sharedApplication().statusBarHidden = true
    titleBar.backgroundColor = MainViewController.blue
//    for (_, constraint) in view.constraints.enumerate() {
//      if constraint.firstItem.isEqual(titleBar) && constraint.firstAttribute == NSLayoutAttribute.Top {
//        constraint.constant = -20
//      }
//    }
//    for (_, constraint) in titleBar.constraints.enumerate() {
//      if constraint.firstItem.isEqual(titleBar) && constraint.firstAttribute == NSLayoutAttribute.Height {
//        constraint.constant = 20
//      }
//    }
//    titleBar.layoutIfNeeded()
    
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
  
  override func viewDidAppear(animated: Bool) {
  }
  
  // Table view
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    cell.load(habits[indexPath.row])
    
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage(named: "Checkmark")),
      color: MainViewController.green,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        tableView.beginUpdates()
        let indexPath = tableView.indexPathForCell(cell)!
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
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
    })
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage(named: "Clock")),
      color: MainViewController.yellow,
      options: [.Rotate, .Alpha],
      completion: { (cell: SwipeTableViewCell) in
        tableView.beginUpdates()
        let indexPath = tableView.indexPathForCell(cell)!
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        let habit = self.habits.removeAtIndex(indexPath.row)
        tableView.endUpdates()
        
        habit.last = NSDate()
        do {
          try self.moContext.save()
        } catch let error as NSError {
          NSLog("Could not save \(error), \(error.userInfo)")
        } catch {
          NSLog("Could not save")
        }
        
        self.insertHabit(habit)
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
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let scale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale);
    view.layer.renderInContext(UIGraphicsGetCurrentContext())
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    let vc = segue.destinationViewController as! HabitViewController
    vc.blurImage = image
    if segue.identifier == showHabitSegue {
      activeCell = sender as? HabitTableViewCell
      vc.habit = activeCell!.habit
    } else if segue.identifier == newHabitSegue {
      vc.habit = Habit.create(moc: moContext, name: "", details: "", frequency: .Daily, times: 1)
    }
  }
  
  @IBAction func unwind(segue: UIStoryboardSegue) {
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
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      } else {
        let habit = habits[indexPath!.row]
        habits = habits.sort({ $0.dueIn < $1.dueIn })
        let newIndex = habits.indexOf(habit)
        if indexPath!.row != newIndex {
          tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Top)
          tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: newIndex!, inSection: 0)], withRowAnimation: .Top)
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

}

