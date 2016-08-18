//
//  Event+CoreDataProperties.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 13/08/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var isComplete: NSNumber?
    @NSManaged var endTime: NSDate?
    @NSManaged var eventDateAndTime: NSDate?
    @NSManaged var eventDescription: String?
    @NSManaged var color: NSNumber?

}
