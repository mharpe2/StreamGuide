//
//  Settings.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/17/16.
//  Copyright © 2016 MJH. All rights reserved.
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?usp=sharing
//https://drive.google.com/file/d/0B73-lYm3LuviUlRPeHpXc3FrY1E/view?
//https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs/export?format=txt


import UIKit

struct MasterLists {
    static let filename = "wsis.txt"
    static let googleDriveLocation = "https://docs.google.com/document/d/1uQ89GhyOHt49-3Zxgg3FpqvWlQko1SlgZpqs-hseeds/export?format=txt"
}

struct Service {
    static let Netflix = "Netflix"
    static let Amazon = "Amazon Prime"
    
}
extension NSDate {
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as NSDate) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as NSDate) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as NSDate) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-M-d"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }

}


//MARK: Extentions

//extension NSDate {
//    func numberOfDaysUntilDateTime(toDateTime: NSDate, inTimeZone timeZone: NSTimeZone? = nil) -> Int {
//        let calendar = NSCalendar.currentCalendar()
//        if let timeZone = timeZone {
//            calendar.timeZone = timeZone
//        }
//        
//        var fromDate: NSDate?, toDate: NSDate?
//        
//        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
//        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
//        
//        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
//        return difference.day
//    }
//}

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
}
