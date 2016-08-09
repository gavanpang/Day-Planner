//
//  Event.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 29/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import Foundation
import CoreData

@objc(Event)
class Event: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func createEvent(moc: NSManagedObjectContext, eventDateAndTime: NSDate) -> Event {
        let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: moc) as! Event;
        newEvent.eventDateAndTime = eventDateAndTime;

        return newEvent;
    }
}
