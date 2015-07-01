//
//  MainViewController.swift
//  Habit
//
//  Created by harry on 6/24/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData

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
  var insertHabit: Habit?
  var removeHabit: NSIndexPath?
  var moveHabit: NSIndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundColor = UIColor.blackColor()
    
//    Habit.create(moc: moContext, name: "1. Hourly 10x", details: "", frequency: .Daily, times: 48)
//    Habit.create(moc: moContext, name: "4. Daily 10x", details: "", frequency: .Daily, times: 10)
//    Habit.create(moc: moContext, name: "5. Daily 5x", details: "", frequency: .Daily, times: 5)
//    Habit.create(moc: moContext, name: "6. Daily 1x", details: "", frequency: .Daily, times: 1)
//    Habit.create(moc: moContext, name: "7. Weekly 10x", details: "", frequency: .Weekly, times: 10)
//    Habit.create(moc: moContext, name: "8. Weekly 5x", details: "", frequency: .Weekly, times: 5)
//    Habit.create(moc: moContext, name: "9. Weekly 1x", details: "", frequency: .Weekly, times: 1)
//    
//    do {
//      try self.moContext.save()
//    } catch let error as NSError {
//      NSLog("Could not save \(error), \(error.userInfo)")
//    } catch {
//      NSLog("Could not save")
//    }
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      habits = try moContext.executeFetchRequest(request) as! [Habit]
      habits = habits.sort({ $0.dueIn() < $1.dueIn() })
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
    if insertHabit != nil {
      let insert = { (habit: Habit, index: Int) -> (Void) in
        self.habits.insert(habit, atIndex: index)
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Fade)
      }
      
      tableView.beginUpdates()
      if habits.count > 0 {
        for index in 0...habits.count {
          if index == habits.count || insertHabit!.dueIn() < habits[index].dueIn() {
            insert(insertHabit!, index)
            break
          }
        }
      } else {
        insert(insertHabit!, 0)
      }
      tableView.endUpdates()
      insertHabit = nil
    }
    
    if removeHabit != nil {
      tableView.deleteRowsAtIndexPaths([removeHabit!], withRowAnimation: .Fade)
      removeHabit = nil
    }
    
    if moveHabit != nil {
      let habit = habits[moveHabit!.row]
      habits = habits.sort({ $0.dueIn() < $1.dueIn() })
      let newIndex = habits.indexOf(habit)
      if moveHabit!.row != newIndex {
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([moveHabit!], withRowAnimation: .Top)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: newIndex!, inSection: 0)], withRowAnimation: .Top)
        tableView.endUpdates()
      } else {
        (tableView.cellForRowAtIndexPath(moveHabit!) as! HabitTableViewCell).reload()
      }
      moveHabit = nil
    }
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
        
        self.insertHabit = habit
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
        
        self.insertHabit = habit
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
    if segue.identifier == showHabitSegue {
      let vc = segue.destinationViewController as! HabitViewController
      activeCell = sender as? HabitTableViewCell
      vc.habit = activeCell!.habit
    } else if segue.identifier == newHabitSegue {
      let vc = segue.destinationViewController as! HabitViewController
      vc.habit = Habit.create(moc: moContext, name: "", details: "", frequency: .Hourly, times: 1)
    }
  }
  
  @IBAction func unwind(segue: UIStoryboardSegue) {
    let vc = segue.sourceViewController as! HabitViewController;
    if activeCell == nil {
      if vc.habit != nil {
        insertHabit = vc.habit
      }
    } else {
      let indexPath = tableView.indexPathForCell(activeCell!)
      tableView.deselectRowAtIndexPath(indexPath!, animated: false)
      if vc.habit == nil {
        habits.removeAtIndex(indexPath!.row)
        removeHabit = indexPath
      } else {
        moveHabit = indexPath
      }
      activeCell = nil
    }
  }

}

