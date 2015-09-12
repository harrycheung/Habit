//
//  ShowHabitViewController.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SnapKit
import KAProgressLabel
import FontAwesome_swift

class ShowHabitViewController: UIViewController, HabitHistoryDelegate {
  
  var habit: Habit?  
  var editHabitTransition: EditHabitTransition?
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var switchMode: UIButton!
  @IBOutlet weak var progressLabel: KAProgressLabel!
  @IBOutlet weak var progressPercentage: UILabel!
  @IBOutlet weak var progressPeriod: UILabel!
  @IBOutlet weak var toolbar: UIView!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var currentStreak: UILabel!
  @IBOutlet weak var longestStreak: UILabel!
  @IBOutlet weak var skipped: UILabel!
  @IBOutlet weak var completed: UILabel!
  @IBOutlet weak var habitHistory: HabitHistory!
  @IBOutlet weak var height: NSLayoutConstraint!
  
  struct AnimationNumbers {
    var completedStart: Int = 0
    var completedEnd: Int = 0
    var percentageStart: CGFloat = 0
    var percentageEnd: CGFloat = 0
    var skippedStart: Int = 0
    var skippedEnd: Int = 0
  }
  var animationNumbers = AnimationNumbers()
  
  func animateNumbers(progress: CGFloat) {
    let percentage = CGFloat(progress - animationNumbers.percentageStart) / CGFloat(animationNumbers.percentageEnd - animationNumbers.percentageStart)
    let currentCompleted = CGFloat(animationNumbers.completedEnd - animationNumbers.completedStart) * percentage + CGFloat(animationNumbers.completedStart)
    let currentSkipped = CGFloat(animationNumbers.skippedEnd - animationNumbers.skippedStart) * percentage + CGFloat(animationNumbers.skippedStart)
    if currentCompleted.isNormal {
      completed.text = "\(Int(currentCompleted))"
    }
    if currentSkipped.isNormal {
      skipped.text = "\(Int(currentSkipped))"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    editHabitTransition = EditHabitTransition()
    
    switchMode.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    switchMode.setTitle(String.fontAwesomeIconWithName(.Cog), forState: .Normal)
    
    progressLabel.labelVCBlock = { (label) in
      self.progressPercentage.text = "\(Int(label.progress * 100))%"
      self.animateNumbers(label.progress)
    }
    progressLabel.progressColor = HabitApp.color
    
    name.text = habit!.name;
    
    back.titleLabel!.font = UIFont.fontAwesomeOfSize(20)
    back.setTitle(String.fontAwesomeIconWithName(.ChevronLeft), forState: .Normal)
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    HabitApp.color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    red += (1 - red) * 0.8
    green += (1 - green) * 0.8
    blue += (1 - blue) * 0.8
    toolbar.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    
    habitHistory.habit = habit!
  }
  
  override func viewWillAppear(animated: Bool) {
    setupStats()
  }
  
  func setupStats() {
    currentStreak.text = "\(habit!.currentStreak!)"
    longestStreak.text = "\(habit!.longestStreak!)"
    skipped.text = "\(habit!.skippedCount())"
    completed.text = "\(habit!.completedCount())"
    progressLabel.setProgress(habit!.progress(), timing: TPPropertyAnimationTimingEaseOut, duration: 0.5, delay: 0.3)
  }
  
  @IBAction func closeView(sender: AnyObject) {
    presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // HabitHistory
  
  private static var dailyFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  private static var dailyYearFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
  }()
  private static var weeklyStartFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM d -\n"
    return formatter
  }()
  private static var monthlyFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
  }()
  private static var monthlyYearFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
  }()
  
  func updateStats(when: AnyObject?, percentage: CGFloat, completedCount: Int, skippedCount: Int) {
    progressLabel.setProgress(percentage, timing: TPPropertyAnimationTimingEaseOut, duration: 0.5, delay: 0)
    animationNumbers.percentageStart = progressLabel.progress
    animationNumbers.percentageEnd = percentage
    animationNumbers.completedStart = Int(completed.text!)!
    animationNumbers.completedEnd = completedCount
    animationNumbers.skippedStart = Int(skipped.text!)!
    animationNumbers.skippedEnd = skippedCount
    
    if let date = when as? NSDate {
      let calendar = HabitApp.calendar
      switch habit!.frequency {
      case .Daily:
        progressPeriod.numberOfLines = 1
        if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Year) {
          if calendar.isDateInToday(NSDate()) {
            progressPeriod.text = "Today"
          } else {
            progressPeriod.text = ShowHabitViewController.dailyFormatter.stringFromDate(date)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.dailyYearFormatter.stringFromDate(date)
        }
      case .Weekly:
        progressPeriod.numberOfLines = 2
        let (startDate, endDate) = Habit.dateRange(date, frequency: .Weekly, includeEnd: false)
        if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Year) {
          if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .WeekOfYear) {
            progressPeriod.text = "This week"
          } else {
            progressPeriod.text = ShowHabitViewController.weeklyStartFormatter.stringFromDate(startDate) +
              ShowHabitViewController.dailyFormatter.stringFromDate(endDate)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.weeklyStartFormatter.stringFromDate(startDate) +
            ShowHabitViewController.dailyYearFormatter.stringFromDate(endDate)
        }
      case .Monthly:
        progressPeriod.numberOfLines = 1
        if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Year) {
          if calendar.isDate(date, equalToDate: NSDate(), toUnitGranularity: .Month) {
            progressPeriod.text = "This month"
          } else {
            progressPeriod.text = ShowHabitViewController.monthlyFormatter.stringFromDate(date)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.monthlyYearFormatter.stringFromDate(date)
        }
      default: ()
      }
    } else {
      progressPeriod.text = when as? String
    }
  
  }
  
  @IBAction func allTimeProgress(sender: AnyObject) {
    habitHistory.clearSelection()
    updateStats("All Time", percentage: habit!.progress(),
      completedCount: habit!.completedCount(), skippedCount: habit!.skippedCount())
  }
  
  func habitHistory(habitHistory: HabitHistory, selectedHistory history: History) {
    updateStats(history.date, percentage: history.percentage,
      completedCount: history.completed!.integerValue, skippedCount: history.skipped!.integerValue)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let vc = segue.destinationViewController as? EditHabitViewController {
      super.prepareForSegue(segue, sender: sender)
      
      vc.habit = self.habit!
      
      segue.destinationViewController.transitioningDelegate = editHabitTransition
      segue.destinationViewController.modalPresentationStyle = .Custom
    }
  }
  
  @IBAction func goToSettings() {
    let ehvc = storyboard!.instantiateViewControllerWithIdentifier("EditHabitViewController") as! EditHabitViewController
    ehvc.transitioningDelegate = editHabitTransition
    ehvc.modalPresentationStyle = .Custom
    ehvc.providesPresentationContextTransitionStyle = true
    ehvc.habit = habit!
    presentViewController(ehvc, animated: true, completion: nil)
  }
  
}