//
//  MainViewController+UITableView.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

extension MainViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let removeRows = { (indexPaths: [NSIndexPath]) in
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Top)
      if self.tabBar.selectedIndex == 0 {
        UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
          self.newButton.alpha = 1
        }
      }
    }
    
    let complete = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      HabitManager.complete(indexPath.row, today: self.tabBar.selectedIndex == 1)
      removeRows([indexPath])
    }
    
    let skip = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      let entry = self.tabBar.selectedIndex == 1 ? HabitManager.today[indexPath.row] : HabitManager.tomorrow[indexPath.row]
      if !entry.habit!.isFake && entry.habit!.hasOldEntries {
        let sdvc = self.storyboard!.instantiateViewControllerWithIdentifier("SwipeDialogViewController") as! SwipeDialogViewController
        sdvc.modalTransitionStyle = .CrossDissolve
        sdvc.modalPresentationStyle = .OverCurrentContext
        sdvc.yesCompletion = {
          // Single out this entry just in case its due > NSDate()
          if entry.due!.compare(NSDate()) == .OrderedDescending {
            HabitManager.skip(indexPath.row, today: self.tabBar.selectedIndex == 1)
          }
          self.dismissViewControllerAnimated(true) {
            removeRows(HabitManager.skip(entry.habit!))
            self.stopReload = false
          }
        }
        sdvc.noCompletion = {
          HabitManager.skip(indexPath.row, today: self.tabBar.selectedIndex == 1)
          self.dismissViewControllerAnimated(true) {
            removeRows([indexPath])
            self.stopReload = false
          }
        }
        self.stopReload = true
        self.presentViewController(sdvc, animated: true, completion: nil)
      } else {
        HabitManager.skip(indexPath.row, today: self.tabBar.selectedIndex == 1)
        removeRows([indexPath])
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HabitTableViewCell
    switch self.tabBar.selectedIndex {
    case 0:
      cell.load(habit: HabitManager.habits[indexPath.row])
    case 1:
      cell.load(entry: HabitManager.today[indexPath.row])
    case 2:
      cell.load(entry: HabitManager.tomorrow[indexPath.row])
    default: ()
    }
    cell.delegate = self
    cell.setSwipeGesture(
      direction: .Right,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.Check, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: Constants.green,
      options: [.Rotate, .Alpha],
      completion: { cell in
        complete(cell)
    })
    cell.setSwipeGesture(
      direction: .Left,
      view: UIImageView(image: UIImage.fontAwesomeIconWithName(.History, textColor: UIColor.whiteColor(), size: CGSizeMake(24, 24))),
      color: Constants.yellow,
      options: [.Rotate, .Alpha],
      completion: { cell in
        skip(cell)
    })
    if tabBar.selectedIndex != 0 || (cell.entry != nil && cell.entry!.habit!.isFake) {
      cell.swipable = true
    } else {
      cell.swipable = false
      //      let button = UIButton(type: .System)
      //      button.setTitle("Can't swipe " + (indexPath.section == 1 ? "upcoming" : "paused"), forState: .Normal)
      //      button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
      //      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 16)!
      //      button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      //      button.backgroundColor = UIColor.darkGrayColor()
      //      button.sizeToFit()
      //      button.roundify(4)
      //      cell.cantSwipeLabel = button
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tabBar.selectedIndex {
    case 0:
      return HabitManager.habitCount
    case 1:
      return HabitManager.todayCount
    case 2:
      return HabitManager.tomorrowCount
    default:
      return 0
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return Constants.TableCellHeight
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
}

extension MainViewController: UITableViewDelegate {
  
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
  
}
