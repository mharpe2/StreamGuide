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
extension Date {
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    static var sharedDateFormatter: DateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-M-d"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }

}



extension String {
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
