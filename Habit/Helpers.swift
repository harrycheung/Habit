//
//  Helpers.swift
//  Habit
//
//  Created by harry on 4/27/16.
//  Copyright © 2016 Harry Cheung. All rights reserved.
//

class Helpers {
  
  static func timeOfDayString(time: Int, short: Bool = false) -> String {
    if time == 0 || time == Constants.dayMinutes {
      return short ? "mid" : "midnight"
    } else {
      let ampm = time < Constants.dayMinutes / 2 ? "am" : "pm"
      var hour = (time / 60) % 12
      if hour == 0 {
        hour = 12
      }
      let minute = time % 60
      let minuteText = minute < 10 ? 0 : ""
      return short ? "\(hour):\(minuteText)\(minute)\(ampm)" : "\(hour):\(minuteText)\(minute) \(ampm)"
    }
  }
  
}
