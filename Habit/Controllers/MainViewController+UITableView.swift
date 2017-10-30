//
//  MainViewController+UITableView.swift
//  Habit
//
//  Created by harry on 4/4/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let removeRows = { (indexPaths: [IndexPath]) in
      tableView.deleteRows(at: indexPaths as [IndexPath], with: .top)
      UIView.animate(withDuration: Constants.NewButtonFadeAnimationDuration) {
        self.newButton.alpha = 1
      }
    }
    
    let complete = { (cell: SwipeTableViewCell) in
      let indexPath = tableView.indexPath(for: cell)!
//      HabitManager.complete(index: indexPath.row, today: self.tabBar.isSelected(title: Constants.TabToday))
      removeRows([indexPath as IndexPath])
    }
    
    let skip = { (cell: SwipeTableViewCell) in
//      let indexPath = tableView.indexPath(for: cell)!
//      let entry = self.tabBar.isSelected(title: Constants.TabToday) ? HabitManager.today[indexPath.row] :
//                                                               HabitManager.upcoming[indexPath.row]
//      if !entry.habit!.isFake && entry.habit!.hasOldEntries {
//        let sdvc = SwipeDialogViewController(nibName: "SwipeDialogViewController", bundle: nil)
//        sdvc.modalTransitionStyle = .crossDissolve
//        sdvc.modalPresentationStyle = .overCurrentContext
//        sdvc.yesCompletion = {
//          // Single out this entry just in case its due > Date()
//          if entry.due! > Date() {
//            HabitManager.skip(index: indexPath.row, today: self.tabBar.isSelected(title: Constants.TabToday))
//          }
//          self.dismiss(animated: true) {
//            removeRows(HabitManager.skip(habit: entry.habit!))
//            self.stopReload = false
//          }
//        }
//        sdvc.noCompletion = {
//          HabitManager.skip(index: indexPath.row, today: self.tabBar.isSelected(title: Constants.TabToday))
//          self.dismiss(animated: true) {
//            removeRows([indexPath])
//            self.stopReload = false
//          }
//        }
//        self.stopReload = true
//        self.present(sdvc, animated: true, completion: nil)
//      } else {
//        HabitManager.skip(index: indexPath.row, today: self.tabBar.isSelected(title: Constants.TabToday))
//        removeRows([indexPath])
//      }
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "HabitTableViewCell",
                                             for: indexPath) as! HabitTableViewCell
//    switch tabBar.selectedItem!.title! {
//    case Constants.TabAll:
//      cell.load(habit: HabitManager.habits[indexPath.row])
//    case Constants.TabToday:
//      cell.load(entry: HabitManager.today[indexPath.row])
//    case Constants.TabUpcoming:
//      cell.load(entry: HabitManager.upcoming[indexPath.row])
//    default: ()
//    }
    cell.load(habit: HabitManager.habits[indexPath.row])
    cell.delegate = self
    let rightImage = UIImage.fontAwesomeIcon(name: .check, textColor: UIColor.white, size: CGSize(width: 40, height: 40))
    cell.setSwipeGesture(direction: .Right,
                         iconView: UIImageView(image: rightImage),
                         color: Constants.green,
                         options: [.Rotate, .Alpha]) { cell in
                          complete(cell)
    }
    let leftImage = UIImage.fontAwesomeIcon(name: .history, textColor: UIColor.white, size: CGSize(width: 40, height: 40))
    cell.setSwipeGesture(direction: .Left,
                         iconView: UIImageView(image: leftImage),
                         color: Constants.yellow,
                         options: [.Rotate, .Alpha]) { cell in
                          skip(cell)
    }

    cell.swipable = true
//    } else {
//      cell.swipable = false
//
//      let button = UIButton(type: .system)
//      button.setTitle("Can't swipe", for: .normal)
//      button.setTitleColor(UIColor.lightGray, for: .normal)
//      button.titleLabel!.font = UIFont(name: "Bariol-Bold", size: 16)!
//      button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
//      button.backgroundColor = UIColor.darkGray
//      button.sizeToFit()
//      button.roundify(radius: 4)
//      cell.cantSwipeLabel = button
//    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return HabitManager.habitCount
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return Constants.TableCellHeight
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
}

extension MainViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // dispatch_async is needed here since selection happens in a new thread
    DispatchQueue.main.async {
      let cell = tableView.cellForRow(at: indexPath as IndexPath) as! HabitTableViewCell
      let shvc = ShowHabitViewController(nibName: String(describing: ShowHabitViewController()), bundle: nil)
      shvc.modalPresentationStyle = .overCurrentContext
      shvc.transitioningDelegate = self.showHabitTransition
      shvc.habit = cell.habit!
      self.present(shvc, animated: true, completion: nil)
    }
  }
  
}
