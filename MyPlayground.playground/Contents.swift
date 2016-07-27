//: Playground - noun: a place where people can play

import UIKit


let today = NSDate.init();

// Printing a date. Use for the title
let dateFormatter = NSDateFormatter.init();
dateFormatter.locale = NSLocale.currentLocale();
//dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle;
//dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle;
dateFormatter.dateFormat = "EEE, MMM dd, yyyy"
var convertedDate = dateFormatter.stringFromDate(today)

// Calendar specifies how the date is structured based on locale
let calendar = NSCalendar.currentCalendar();

// Make a date by specifying it
let dateComp = NSDateComponents.init();
dateComp.year = 2016;
dateComp.month = 7;
dateComp.day = 10;
dateComp.hour = 23;
dateComp.minute = 45;
dateComp.second = 59;

let specifiedDate = calendar.dateFromComponents(dateComp);
