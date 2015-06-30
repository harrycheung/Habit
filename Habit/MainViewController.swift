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
  
  let moContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  let cellIdentifier = "HabitCell"
  let showHabitSegue = "ShowHabit"
  let newHabitSegue = "NewHabit"

  @IBOutlet weak var tableView: UITableView!
  
  var activeCell: HabitTableViewCell?
  var habits = [Habit]()
  var insertHabit: Habit?
  var removeHabit: NSIndexPath?
  var moveHabit: NSIndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()

//    Habit.create(moc: moContext, name: "1. Hourly 10x", details: "", frequency: .Hourly, times: 10)
//    Habit.create(moc: moContext, name: "2. Hourly 5x", details: "", frequency: .Hourly, times: 5)
//    Habit.create(moc: moContext, name: "3. Hourly 1x", details: "", frequency: .Hourly, times: 1)
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
    NSLog("viewDidAppear")
    
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
      color: UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1),
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
      color: UIColor(red: 254.0 / 255.0, green: 217.0 / 255.0, blue: 56.0 / 255.0, alpha: 1),
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
    NSLog("didSelectRowAtIndexPath \(indexPath)")
    let cell = tableView.cellForRowAtIndexPath(indexPath) as! HabitTableViewCell
    NSLog("name: \(cell.habit!.name)")
    dispatch_async(dispatch_get_main_queue()) {
      self.performSegueWithIdentifier(self.showHabitSegue, sender: tableView.cellForRowAtIndexPath(indexPath))
    }
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    NSLog("MainViewController.prepareForSegue")
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
        habits.append(vc.habit!)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: habits.count - 1, inSection: 0)],
          withRowAnimation: UITableViewRowAnimation.Top)
        tableView.endUpdates()
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

