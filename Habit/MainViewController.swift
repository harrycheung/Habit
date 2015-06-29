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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
//    
//    Habit.create(moc: moContext, name: "1. Daily 10x", details: "", frequency: 0, times: 10)
//    Habit.create(moc: moContext, name: "2. Daily 5x", details: "", frequency: 0, times: 5)
//    Habit.create(moc: moContext, name: "3. Daily 1x", details: "", frequency: 0, times: 1)
//    Habit.create(moc: moContext, name: "4. Weekly 10x", details: "", frequency: 1, times: 10)
//    Habit.create(moc: moContext, name: "5. Weekly 5x", details: "", frequency: 1, times: 10)
//    Habit.create(moc: moContext, name: "6. Weekly 1x", details: "", frequency: 1, times: 10)
//    
//    do {
//      try self.moContext.save()
//    } catch let error as NSError {
//      NSLog("Could not save \(error), \(error.userInfo)")
//    } catch {
//      NSLog("Could not save")
//    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // Table view
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    cell.load(habits[indexPath.row])
  
    let image = UIImageView(image: UIImage(named: "Checkmark"))
    let color = UIColor(red: 85.0 / 255.0, green: 213.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
    cell.setSwipeGesture(
      direction: .Right,
      view: image,
      color: color,
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
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "insertHabit:", userInfo: [habit],
          repeats: false)
    })
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return habits.count
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  func insertHabit(timer: NSTimer) {
    let insert = { (habit: Habit, index: Int) -> (Void) in
      self.habits.insert(habit, atIndex: index)
      self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)], withRowAnimation: .Fade)
    }
    
    tableView.beginUpdates()
    
    let habit = (timer.userInfo as! [Habit])[0]
    if habits.count > 0 {
      for index in 0...habits.count {
        if index == habits.count || habit.dueIn() < habits[index].dueIn() {
          insert(habit, index)
          break
        }
      }
    } else {
      insert(habit, 0)
    }
    
    tableView.endUpdates()
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == showHabitSegue {
      let vc = segue.destinationViewController as! HabitViewController
      activeCell = sender as? HabitTableViewCell
      vc.habit = activeCell!.habit
    } else if segue.identifier == newHabitSegue {
      let vc = segue.destinationViewController as! HabitViewController
      vc.habit = Habit.create(moc: moContext, name: "", details: "", frequency: 0, times: 1)
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
        tableView.reloadData()
      } else {
        tableView.beginUpdates()
        activeCell!.reload()
        tableView.endUpdates()
      }
      activeCell = nil
    }
  }

}

