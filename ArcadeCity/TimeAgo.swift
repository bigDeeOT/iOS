//
//  TimeAgo.swift
//  ArcadeCity
//
//  Created by Dewayne Perry on 7/22/17.
//  Copyright © 2017 The University of Texas at Austin. All rights reserved.
//

import Foundation

class TimeAgo {
    static func get(_ date: Date) -> String {
        var timeAgo = "unknown"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let dateInTime = " at " + dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM d"
        let dayOfTheYear = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MMM d yyyy"
        let datePeriod = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let yearOfDate = dateFormatter.string(from: date)
        let yearOfToday = dateFormatter.string(from: Date.init())
        let calendar = Calendar.current
        let dayNumber = Calendar.current.component(.weekday, from: date) - 1
        let todaysDayNumber = calendar.component(.weekday, from: Date.init()) - 1
        let dayOfTheWeek = DateFormatter().weekdaySymbols[dayNumber]
        let current = Date.init()
        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let time = Int(current.timeIntervalSince(date))
        if time < 3 {
            timeAgo = "Just now"
        } else if time < minute {
            timeAgo = String(describing: time) + " secs ago"
        } else if (time >= minute) && (time <= 2 * minute) {
            timeAgo = "1 min ago"
        } else if (time >= minute) && (time < hour) {
            timeAgo = String(describing: time / minute) + " mins ago"
        }  else if (time >= hour) && (time < 2 * hour) {
            timeAgo = "1 hour"
        } else if (time >= hour) && (time < day) {
            timeAgo = String(describing: time / hour) + " hours ago"
        } else if (time >= day) && (time < 2 * day) {
            timeAgo = "Yesterday" + dateInTime
        } else if (time >= day) && (time < week) {
            if (dayNumber >= todaysDayNumber) && ((dayNumber - todaysDayNumber) <= 3) {
                timeAgo = "Last " + dayOfTheWeek + dateInTime
            } else {
               timeAgo = dayOfTheWeek + dateInTime
            }
        } else if time > week {
            if yearOfDate == yearOfToday {
                timeAgo = dayOfTheYear + dateInTime
            } else {
                timeAgo = datePeriod + dateInTime
            }
        }
        return timeAgo
    }
    
    static func get(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy hh:mm:ss a"
        if let dateClass = dateFormatter.date(from: date) {
            return get(dateClass)
        } else {
            return date
        }
    }
}




