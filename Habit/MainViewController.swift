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

  @IBOutlet weak var tableView: UITableView!
  
  var activeCell: HabitTableViewCell?
  var habits = [Habit]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let request = NSFetchRequest(entityName: "Habit")
    do {
      habits = try moContext.executeFetchRequest(request) as! [Habit]
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
        let indexPath = tableView.indexPathForCell(cell)!
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: self.habits.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
        let habit = self.habits.removeAtIndex(indexPath.row)
        self.habits.append(habit)
        tableView.endUpdates()
      })
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return habits.count
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  // Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowHabit" {
      let vc = segue.destinationViewController as! HabitViewController
      activeCell = sender as? HabitTableViewCell
      vc.habit = activeCell!.habit
    } else if segue.identifier == "NewHabit" {
      let vc = segue.destinationViewController as! HabitViewController
      vc.habit = Habit.create(moc: moContext, name: "", details: "", `repeat`: 0, times: 1)
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

