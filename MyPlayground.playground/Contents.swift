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
dateComp.month = 8;
dateComp.day = 21;
dateComp.hour = 23;
dateComp.minute = 45;
dateComp.second = 59;

let specifiedDate1 = calendar.dateFromComponents(dateComp);

dateComp.year = 2016;
dateComp.month = 8;
dateComp.day = 23;
dateComp.hour = 3;
dateComp.minute = 45;
dateComp.second = 59;

let specifiedDate2 = calendar.dateFromComponents(dateComp);

let isTomorrow = calendar.isDateInTomorrow(specifiedDate2!);
let isYesterday = calendar.isDateInYesterday(specifiedDate1!);
