//
//  Logger+CoreDataProperties.swift
//  EPIAL
//
//  Created by Juli on 18/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Logger {
    @NSManaged var treatmentDuration: NSNumber?
    @NSManaged var preTreatmentPainLevel: NSNumber?
    @NSManaged var postTreatmentPainLevel : NSNumber?
    @NSManaged var dateTime: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var categories: String?
    @NSManaged var date: String?
    @NSManaged var frequency: NSNumber?
    @NSManaged var current: NSNumber?
    @NSManaged var treatmentArea: String?
    @NSManaged var dateWithoutTime: String?
}
