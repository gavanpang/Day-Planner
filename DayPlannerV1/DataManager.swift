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
    
    // MARK: Persistent storage
    
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext;
    
    // Data store for user preferences and program defaults
    private let prefs : NSUserDefaults = NSUserDefaults.standardUserDefaults();
    
    // MARK: Misc helper variables
    
    // Date of the last time the app data was reloaded/recalculated
    var lastDataReloadDate : NSDate!;
    
    // To be used for date maths
    let calendar : NSCalendar = NSCalendar.currentCalendar();
    
    // Colors used by everyone
    var allColors : [UIColor] = [UIColor.orangeColor(), UIColor.blueColor(), UIColor.redColor(),
                                 UIColor.yellowColor(), UIColor.greenColor(), UIColor.cyanColor()];
    
    // MARK:  Main view variables
    
    // Date of which events to be currently displayed
    var currentIndex : Int = 0;   // Change this to be read from plist later
    
    // The array of dates for the next 2 weeks
    var nextFourteenDates : [NSDate] = [];
    
    // The date of the current page
    var currentViewDate : NSDate!;
    
    // Valid Min/Max range for the current view
    var currentViewDateMin : NSDate?;
    var currentViewDateMax : NSDate?;
    
    // The Events of the current view
    var currentViewEvents : [Event]?;
    
    // MARK: Left view variables
    
    var lastSelectedTab : Int = 0;
    
    // Overdue events
    var overdueEvents : [Event]?;
    
    // Pending allocation events
    
    // Recurring events
    
    private init() {
        
        // Read app settings from disk
        let path = NSBundle.mainBundle().pathForResource("DefaultSettings", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        
        self.prefs.setObject(dict, forKey: "defaults");
        
        // Set up presets
        self.setUpDates();
        
        // Unpack the NSUserDefaults
        self.loadAppDefaults();
    }

    
// MARK: - Functions to check whether data needs to be reloaded
    // Data reloads to occur after 2am every morning
    func doesDataNeedRefreshing(lastRefreshDate: NSDate) -> Bool {
        
        // Force-check if internal data is out of date, then the view controller's is definitely 
        // out of date
        if(self.didInternalDataRefresh() == true) {
            return true;
        }
        
        // Otherwise check whether enough time has elapsed from the view controller's date
        return self.isItTimeToRefreshData(lastRefreshDate);
    }
    
    // Forces a check whether it's time to refresh the data. Returns true if data just got refreshed in 
    // DataManager
    func didInternalDataRefresh() -> Bool {
        
        // If it's not time to refresh, then don't...
        if(self.isItTimeToRefreshData(self.lastDataReloadDate) == false) {
            return false;
        }
        
        // Reload as must be older than yesterday, basically re-init the whole datamanager
        self.resetAllDataToNil();
        self.setUpDates();
        self.loadAppDefaults();
        
        // Also redo the database
        
        // 1. Delete completed events
        
        // 2. Reprocess recurring events
        
        return true;
    }
    
    func isItTimeToRefreshData(date: NSDate) -> Bool {
        // See if it's been more than a day since the last data reload
        let wasDataReloadedToday = self.calendar.isDateInToday(date);
        
        // If reloading was today, no need to reload again
        if(wasDataReloadedToday == true) {
            return false;
        }
        
        // If it was reloaded yesterday, check whether it's currently past 2am yet
        let wasDataReloadedYesterday = self.calendar.isDateInYesterday(date);
        
        if(wasDataReloadedYesterday == true) {
            let todayHour = self.calendar.component(NSCalendarUnit.Hour, fromDate: NSDate());
            
            if(todayHour < 2) {
                return false;
            }
        }
        
        return true;
    }
    
// MARK: - Time and Date helpers
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
    
    
// MARK: - External accessors
    
    func loadFutureEventsWithIndex(index: Int) -> [Event] {
        
        self.setCurrentViewDateWithIndex(index);
        
        print("Current date", self.currentViewDate);
        
        // Pull all the events for the view, between the yesterday and tomorrow (ie today only,
        // today being the date of the current view)
        
        // Get this morning's midnight and tonight's midnight
        self.currentViewDateMin = self.calculateValidMinimumForDate(self.currentViewDate);
        self.currentViewDateMax = self.calculateValidMaximumForDate(self.currentViewDate);
        
        // Construct the predicate
        let pred = NSPredicate(format: "(eventDateAndTime > %@) AND (eventDateAndTime < %@)", self.currentViewDateMin!, self.currentViewDateMax!);
        
        //print("Events between", yesterdayMidnight, tomorrowMidnight);
        
        // Sort the fetched dates in order
        let sortDescriptor = NSSortDescriptor(key: "eventDateAndTime", ascending: true)
        
        // Form the fetch request with predicate
        let fetchRequest = NSFetchRequest(entityName: "Event");
        
        fetchRequest.predicate = pred;
        fetchRequest.sortDescriptors = [sortDescriptor];
        
        let fetchResults : [Event];
        
        do {
            try fetchResults =  (self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Event])!;
            self.currentViewEvents = fetchResults;
        } catch let error as NSError  {
            print("Could not fetch from MOC \(error), \(error.userInfo)")
        }
        
        // Save the current view to defaults
        self.prefs.setInteger(index, forKey: "currentIndex");
        
        return self.currentViewEvents!;
    }
    
    func loadOverdueEvents() -> [Event] {
        // Construct the predicate
        let todayMin = self.calculateValidMinimumForDate(NSDate());
        print(todayMin);
        let pred = NSPredicate(format: "eventDateAndTime < %@", todayMin);
        
        // Sort the fetched dates in order
        let sortDescriptor = NSSortDescriptor(key: "eventDateAndTime", ascending: true)
        
        // Form the fetch request with predicate
        let fetchRequest = NSFetchRequest(entityName: "Event");
        
        fetchRequest.predicate = pred;
        fetchRequest.sortDescriptors = [sortDescriptor];
        
        let fetchResults : [Event];
        
        do {
            try fetchResults =  (self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Event])!;
            self.overdueEvents = fetchResults;
        } catch let error as NSError  {
            print("Could not fetch from MOC \(error), \(error.userInfo)")
        }
    
        
        return self.overdueEvents!;
    }

    
// MARK: - Helpers
    
    func setCurrentViewDateWithIndex(index: Int) {
        self.currentIndex = index;
        
        self.currentViewDate = self.nextFourteenDates[self.currentIndex];
    }
    
    private func calculateValidMinimumForDate(date: NSDate) -> NSDate {
        // Get this morning's midnight
        let comps = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date);
        comps.hour = 0;
        comps.minute = 0;
        comps.second = 0;
        
        return self.calendar.dateFromComponents(comps)!;
    }
    
    private func calculateValidMaximumForDate(date: NSDate) -> NSDate {
        // Get tonight's midnight
        let comps = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date);
        comps.hour = 0;
        comps.minute = 0;
        comps.second = 0;
        
        comps.day += 1;
        
        return self.calendar.dateFromComponents(comps)!;
    }
    
    func currentViewDateWithTime(hours: Int, minutes: Int) -> NSDate {
        let components = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self.currentViewDate);
        
        components.hour = hours;
        components.minute = minutes;
        
        return self.calendar.dateFromComponents(components)!;
    }
    
    func isDateWithinCurrentViewDate(date: NSDate) -> Bool {
        let compResult = self.calendar.compareDate(self.currentViewDateMin!, toDate: date, toUnitGranularity: NSCalendarUnit.Day)
        
        if(compResult == NSComparisonResult.OrderedSame) {
            return true;
        } else {
            return false;
        }
    }

    func resetAllDataToNil() {
        self.nextFourteenDates.removeAll();
        
    }
    
// MARK: - Setup
    func setUpDates() {
        // Or set appropriate value
        let today = NSDate();
        let oneDay = NSDateComponents();
        
        for i in 0...13 {
            oneDay.day = i;
            let newDate = self.calendar.dateByAddingComponents(oneDay, toDate: today, options: [])
            self.nextFourteenDates.append(newDate!);
        }
    }

    // Loads app settings, and sets the variables that the view needs
    private func loadAppDefaults() {
        
        // Last selected tab in left panel
        self.lastSelectedTab = self.prefs.integerForKey("lastSelectedTab");
        
        ///////////////////////////////////
        // Main View setup
        ///////////////////////////////////
        // Get the list number that was last used when app closed
        let lastOpenIndex = self.prefs.integerForKey("currentIndex");
        
        // Calculate the proper offset so that the correct date/page is displayed
        self.lastDataReloadDate = self.prefs.objectForKey("lastReloadDate") as? NSDate;
        
        let today = NSDate();
        
        if(self.lastDataReloadDate == nil) {
            // Very first program execution, save the current date as the last reload
            
            self.currentIndex = lastOpenIndex;
            
        } else {
            // Not first program execution
            
            // See how long since the program was last opened
            let comps = self.calendar.components([NSCalendarUnit.Day], fromDate: self.lastDataReloadDate, toDate: today, options: []);
            
            // If it's been more than 2 weeks, default the view to today
            if(comps.day > 13) {
                self.currentIndex = 0;
            }
            
            // Otherwise calculate which day was the last opened and display that instead
            else {
                self.currentIndex = lastOpenIndex - comps.day;
                
                // Lower bounds check
                if(self.currentIndex < 0) {
                    self.currentIndex = 0;
                }
            }
        }
        
        // Update the current view date
        self.currentViewDate = self.nextFourteenDates[self.currentIndex];
        
        // Finally, update the last data reload date
        self.lastDataReloadDate = today;
        self.prefs.setObject(today, forKey: "lastReloadDate");
    }
    
    // MARK: - Left Panel
    func setLastSelectedTab(tabNum : Int) {
        self.lastSelectedTab = tabNum;
        self.prefs.setObject(tabNum, forKey: "lastSelectedTab");
    }
    
    
// MARK: - Managed Object Context
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