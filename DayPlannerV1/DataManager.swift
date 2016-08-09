//
//  DataManager.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 9/08/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

// DataManager handles all I/O operations, as well as managing objects in memory

import Foundation
import UIKit
import CoreData

class DataManager {
    // New singleton declaration
    static let sharedInstance = DataManager();
    
    // Date of which events to be currently displayed
    var currentIndex : Int = 0;   // Change this to be read from plist later
    
    // The date of the current page
    var currentViewDate : NSDate!;
    
    // To be used for date maths
    let calendar : NSCalendar       = NSCalendar.currentCalendar();
    
    // The array of dates for the next 2 weeks
    var nextFourteenDates : [NSDate] = [];
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext;
    
    // The Events of the current date
    var thisDateEvents : [Event]?;
    
    private init() {
        // Unpack the NSUserDefaults
        
        self.currentIndex = 0; // Read this from disk
        self.setUpDates();
        
        /*
        let path = NSBundle.mainBundle().pathForResource("DefaultSettings", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        self.prefs.setObject(dict, forKey: "defaults");
        self.prefs.synchronize();
        
        // Get the list number that was last used when app closed
        self.currentActiveListNumber = self.prefs.integerForKey("currentListNumber");
        
        // Load the list number
        self.currentToDoList = self.loadList(self.currentActiveListNumber);
         */
    }
    
// MARK : - Something
    func loadEventsWithIndex(index: Int) -> [Event] {
        
        
        // Index -1 is used when loading up, not switching views
        if(index != -1) {
            self.setCurrentViewDateWithIndex(index);
        }
        
        // Pull all the events for the view, between the yesterday and tomorrow (ie today only)
        
        // Get this morning's midnight and tonight's midnight
        let comps = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self.currentViewDate);
        comps.hour = 0;
        comps.minute = 0;
        comps.second = 0;
        
        let yesterdayMidnight = self.calendar.dateFromComponents(comps);
        
        comps.day += 1;
        
        let tomorrowMidnight = self.calendar.dateFromComponents(comps);
        
        // Construct the predicate
        let pred = NSPredicate(format: "(eventDateAndTime > %@) AND (eventDateAndTime < %@)", yesterdayMidnight!, tomorrowMidnight!);
        
        print("Events between", yesterdayMidnight, tomorrowMidnight);
        
        // Sort the fetched dates in order
        let sortDescriptor = NSSortDescriptor(key: "eventDateAndTime", ascending: true)
        
        // Form the fetch request with predicate
        let fetchRequest = NSFetchRequest(entityName: "Event");
        
        fetchRequest.predicate = pred;
        fetchRequest.sortDescriptors = [sortDescriptor];
        
        let fetchResults : [Event];
        
        do {
            try fetchResults =  (self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Event])!;
                self.thisDateEvents = fetchResults;
        } catch let error as NSError  {
            print("Could not fetch from MOC \(error), \(error.userInfo)")
        }
        
        return self.thisDateEvents!;
        
        //self.prefs.setInteger(newListNumber, forKey: "currentListNumber");
        //self.synchronize();
    }
    
// MARK : - Time and Date helpers
    func timeDateRoundUpFifteenMinutes(targetTime : NSDate) -> NSDate {
        
        // Combine the date of the current view with the current time
        let currentViewDateAndTimeComponents = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.TimeZone], fromDate: self.currentViewDate);
        
        // Do the current time, round up to the next 15 minutes
        currentViewDateAndTimeComponents.hour = self.calendar.component(NSCalendarUnit.Hour, fromDate: targetTime);
        let minute = self.calendar.component(NSCalendarUnit.Minute, fromDate: targetTime);
        
        if(minute > 0) {
            currentViewDateAndTimeComponents.minute = 15;
        }
        
        if(minute > 15) {
            currentViewDateAndTimeComponents.minute = 30;
        }
        
        if(minute > 30) {
            currentViewDateAndTimeComponents.minute = 45;
        }
        
        if(minute > 45) {
            currentViewDateAndTimeComponents.hour += 1;
            currentViewDateAndTimeComponents.minute = 0;
        }
        
        // Finally convert it to NSDate, and store to be accessed by EventDetailsViewController
        let roundedTime = self.calendar.dateFromComponents(currentViewDateAndTimeComponents);
        return roundedTime!;
    }
    
    func currentViewDateWithTime(hours: Int, minutes: Int) -> NSDate {
        let components = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self.currentViewDate);
        
        components.hour = hours;
        components.minute = minutes;
        
        return self.calendar.dateFromComponents(components)!;
    }
    
// MARK : - Helpers
    func setUpDates() {
        // Or set appropriate value
        let today = NSDate();
        let oneDay = NSDateComponents();
        
        for i in 0...13 {
            oneDay.day = i;
            let newDate = self.calendar.dateByAddingComponents(oneDay, toDate: today, options: [])
            self.nextFourteenDates.append(newDate!);
            print(newDate);
        }
        
        // Set up the current view with the correct date
        self.currentViewDate = self.nextFourteenDates[self.currentIndex];
    }
    
    func setCurrentViewDateWithIndex(index: Int) {
        self.currentIndex = index;
        
        self.currentViewDate = self.nextFourteenDates[self.currentIndex];
    }

// MARK : - Managed Object Context
    func createEvent(startDateAndTime: NSDate) -> Event {
        return Event.createEvent(self.managedObjectContext, eventDateAndTime: startDateAndTime);
    }
    
    func eventWithID(objectID: NSManagedObjectID) -> Event {
        return self.managedObjectContext.objectWithID(objectID) as! Event;
    }
    
    func update() {
        do {
            try self.managedObjectContext.save()
        }
        catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteEvent(event: Event) {
        self.managedObjectContext.deleteObject(event);
    }

}