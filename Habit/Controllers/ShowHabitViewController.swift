//
//  ShowHabitViewController.swift
//  Habit
//
//  Created by harry on 6/25/15.
//  Copyright (c) 2015 Harry Cheung. All rights reserved.
//

import UIKit
import CoreData
import KAProgressLabel
import FontAwesome_swift

class ShowHabitViewController: UIViewController {
  
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var switchMode: UIButton!
  @IBOutlet weak var progressLabel: KAProgressLabel!
  @IBOutlet weak var progressPercentage: UILabel!
  @IBOutlet weak var progressPeriod: UILabel!
  @IBOutlet weak var back: UIButton!
  @IBOutlet weak var frequency: UILabel!
  @IBOutlet weak var frequencyValue: UILabel!
  @IBOutlet weak var currentStreak: UILabel!
  @IBOutlet weak var longestStreak: UILabel!
  @IBOutlet weak var skipped: UILabel!
  @IBOutlet weak var completed: UILabel!
  @IBOutlet weak var habitHistory: HabitHistory!
  @IBOutlet weak var height: NSLayoutConstraint!
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var contentView: UIView!
  
  var habit: Habit!
  var editHabitTransition: EditHabitTransition!
  
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
    let percentage = CGFloat(progress - animationNumbers.percentageStart) /
                     CGFloat(animationNumbers.percentageEnd - animationNumbers.percentageStart)
    let currentCompleted = CGFloat(animationNumbers.completedEnd - animationNumbers.completedStart) * percentage +
                           CGFloat(animationNumbers.completedStart)
    let currentSkipped = CGFloat(animationNumbers.skippedEnd - animationNumbers.skippedStart) * percentage +
                         CGFloat(animationNumbers.skippedStart)
    if currentCompleted.isNormal {
      completed.text = "\(Int(currentCompleted))"
    }
    if currentSkipped.isNormal {
      skipped.text = "\(Int(currentSkipped))"
    }
  }
  
  func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    editHabitTransition = EditHabitTransition()
    
    switchMode.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
    switchMode.setTitle(String.fontAwesomeIcon(name: .cog), for: .normal)
    if habit.isFake { switchMode.isHidden = true }
    
    progressLabel.labelVCBlock = { label in
      self.progressPercentage.text = "\(Int((label?.progress)! * 100))%"
      self.animateNumbers(progress: (label?.progress)!)
    }
    progressLabel.progressColor = HabitApp.color
    
    name.text = habit.isFake ? "Example habit" : habit.name
    
    back.titleLabel!.font = UIFont.fontAwesome(ofSize: 20)
    back.setTitle(String.fontAwesomeIcon(name: .chevronLeft), for: .normal)
    
    frequency.text = habit.frequency.description
    let times = habit.useTimes ? habit.times : Int32(habit.partsArray.count)
    switch times {
    case 1:
      frequencyValue.text = "once"
    case 2:
      frequencyValue.text = "twice"
    default:
      frequencyValue.text = "\(times) times"
    }
    
    habitHistory.habit = habit
    habitHistory.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupStats()
  }
  
  private func setupStats() {
    currentStreak.text = "\(habit.currentStreak)"
    longestStreak.text = "\(habit.longestStreak)"
    skipped.text = "\(habit.skipped)"
    completed.text = "\(habit.completed)"
    progressLabel.setProgress(habit.progress(date: Date()),
                              timing: TPPropertyAnimationTimingEaseOut,
                              duration: 0.5,
                              delay: 0.3)
  }
  
  @IBAction func closeView(sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }
  
  // HabitHistory
  
  private static var dailyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
  }()
  private static var dailyYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
  }()
  private static var weeklyStartFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d -\n"
    return formatter
  }()
  private static var monthlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
  }()
  private static var monthlyYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
  }()
  
  private func updateStats(when: AnyObject?, percentage: CGFloat, completedCount: Int, skippedCount: Int) {
    progressLabel.setProgress(percentage, timing: TPPropertyAnimationTimingEaseOut, duration: 0.5, delay: 0)
    animationNumbers.percentageStart = progressLabel.progress
    animationNumbers.percentageEnd = percentage
    animationNumbers.completedStart = Int(completed.text!)!
    animationNumbers.completedEnd = completedCount
    animationNumbers.skippedStart = Int(skipped.text!)!
    animationNumbers.skippedEnd = skippedCount
    
    if let date = when as? Date {
      let calendar = HabitApp.calendar
      switch habit.frequency {
      case .Daily:
        progressPeriod.numberOfLines = 1
        if calendar.isDate(date, equalTo: Date(), toUnitGranularity: .year) {
          if calendar.isDateInToday(date) {
            progressPeriod.text = "Today"
          } else {
            progressPeriod.text = ShowHabitViewController.dailyFormatter.string(from: date)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.dailyYearFormatter.string(from: date)
        }
      case .Weekly:
        progressPeriod.numberOfLines = 2
        let (startDate, endDate) = Habit.dateRange(date: date, frequency: .Weekly, includeEnd: false)
        if calendar.isDate(date, equalTo: Date(), toUnitGranularity: .year) {
          if calendar.isDate(date, equalTo: Date(), toUnitGranularity: .weekOfYear) {
            progressPeriod.text = "This week"
          } else {
            progressPeriod.text = ShowHabitViewController.weeklyStartFormatter.string(from: startDate as Date) +
              ShowHabitViewController.dailyFormatter.string(from: endDate as Date)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.weeklyStartFormatter.string(from: startDate as Date) +
            ShowHabitViewController.dailyYearFormatter.string(from: endDate as Date)
        }
      case .Monthly:
        progressPeriod.numberOfLines = 1
        if calendar.isDate(date, equalTo: Date(), toUnitGranularity: .year) {
          if calendar.isDate(date, equalTo: Date(), toUnitGranularity: .month) {
            progressPeriod.text = "This month"
          } else {
            progressPeriod.text = ShowHabitViewController.monthlyFormatter.string(from: date)
          }
        } else {
          progressPeriod.text = ShowHabitViewController.monthlyYearFormatter.string(from: date)
        }
      default: ()
      }
    } else {
      progressPeriod.text = when as? String
    }
  
  }
  
  @IBAction func allTimeProgress(sender: AnyObject) {
    habitHistory.clearSelection()
    updateStats(when: "All time" as AnyObject,
                percentage: habit.progress(date: Date()),
                completedCount: Int(habit.completed),
                skippedCount: Int(habit.skipped))
  }
  
  @IBAction func goToSettings() {
    let ehvc = EditHabitViewController(nibName: String(describing: EditHabitViewController()), bundle: nil)
    ehvc.transitioningDelegate = editHabitTransition
    ehvc.modalPresentationStyle = .custom
    ehvc.habit = habit
    ehvc.frequency = habit.frequency
    present(ehvc, animated: true, completion: nil)
  }
  
}

extension ShowHabitViewController: HabitHistoryDelegate {
  
  func habitHistory(habitHistory: HabitHistory, selectedHistory history: History) {
    updateStats(when: history.date as AnyObject,
                percentage: history.percentage,
                completedCount: Int(history.completed),
                skippedCount: Int(history.skipped))
  }
  
}
