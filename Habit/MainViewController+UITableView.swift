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
      if self.tabBar.isSelected(Constants.TabAll) {
        UIView.animateWithDuration(Constants.NewButtonFadeAnimationDuration) {
          self.newButton.alpha = 1
        }
      }
    }
    
    let complete = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      HabitManager.complete(indexPath.row, today: self.tabBar.isSelected(Constants.TabToday))
      removeRows([indexPath])
    }
    
    let skip = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPathForCell(cell)!
      let entry = self.tabBar.isSelected(Constants.TabToday) ? HabitManager.today[indexPath.row] : HabitManager.upcoming[indexPath.row]
      if !entry.habit!.isFake && entry.habit!.hasOldEntries {
        let sdvc = self.storyboard!.instantiateViewControllerWithIdentifier(String(SwipeDialogViewController)) as! SwipeDialogViewController
        sdvc.modalTransitionStyle = .CrossDissolve
        sdvc.modalPresentationStyle = .OverCurrentContext
        sdvc.yesCompletion = {
          // Single out this entry just in case its due > NSDate()
          if entry.due!.compare(NSDate()) == .OrderedDescending {
            HabitManager.skip(indexPath.row, today: self.tabBar.isSelected(Constants.TabToday))
          }
          self.dismissViewControllerAnimated(true) {
            removeRows(HabitManager.skip(entry.habit!))
            self.stopReload = false
          }
        }
        sdvc.noCompletion = {
          HabitManager.skip(indexPath.row, today: self.tabBar.isSelected(Constants.TabToday))
          self.dismissViewControllerAnimated(true) {
            removeRows([indexPath])
            self.stopReload = false
          }
        }
        self.stopReload = true
        self.presentViewController(sdvc, animated: true, completion: nil)
      } else {
        HabitManager.skip(indexPath.row, today: self.tabBar.isSelected(Constants.TabToday))
        removeRows([indexPath])
      }
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(String(HabitTableViewCell), forIndexPath: indexPath) as! HabitTableViewCell
    switch tabBar.selectedItem!.title! {
    case Constants.TabAll:
      cell.load(habit: HabitManager.habits[indexPath.row])
    case Constants.TabToday:
      cell.load(entry: HabitManager.today[indexPath.row])
    case Constants.TabUpcoming:
      cell.load(entry: HabitManager.upcoming[indexPath.row])
    default: ()
    }
    cell.delegate = self
    let rightImage = UIImage.fontAwesomeIconWithName(.Check, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40))
    cell.setSwipeGesture(direction: .Right,
                         iconView: UIImageView(image: rightImage),
                         color: Constants.green,
                         options: [.Rotate, .Alpha]) { cell in
                          complete(cell)
    }
    let leftImage = UIImage.fontAwesomeIconWithName(.History, textColor: UIColor.whiteColor(), size: CGSizeMake(40, 40))
    cell.setSwipeGesture(direction: .Left,
                         iconView: UIImageView(image: leftImage),
                         color: Constants.yellow,
                         options: [.Rotate, .Alpha]) { cell in
                          skip(cell)
    }
    if !tabBar.isSelected(Constants.TabAll) || (cell.entry != nil && cell.entry!.habit!.isFake) {
      cell.swipable = true
    } else {
      cell.swipable = false
      
      let button = UIButton(type: .System)
      button.setTitle("Can't swipe", forState: .Normal)
      button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 16)!
      button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
      button.backgroundColor = UIColor.darkGrayColor()
      button.sizeToFit()
      button.roundify(4)
      cell.cantSwipeLabel = button
    }
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch tabBar.selectedItem!.title! {
    case Constants.TabAll:
      return HabitManager.habitCount
    case Constants.TabToday:
      return HabitManager.todayCount
    case Constants.TabUpcoming:
      return HabitManager.upcomingCount
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
