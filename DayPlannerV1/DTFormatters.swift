//
//  DTFormatters.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 2/08/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import Foundation

class DTFormatters {
    static let sharedInstance = DTFormatters();
    
    // Dates
    private let dateFormatter = NSDateFormatter.init();
    
    // Times
    private let timeFormatter = NSDateFormatter.init();
    
    private init() {
        self.dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        self.timeFormatter.dateFormat = "HH:mm";
    }
    
    func stringFromDate(date: NSDate) -> String {
        return self.dateFormatter.stringFromDate(date);
    }
    
    func stringFromTime(time: NSDate) -> String {
        return self.timeFormatter.stringFromDate(time);
    }
}
