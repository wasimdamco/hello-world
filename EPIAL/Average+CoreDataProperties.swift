//
//  Average+CoreDataProperties.swift
//  EPIAL
//
//  Created by User on 23/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import Foundation
import CoreData


extension Average {

   
    @NSManaged  var categories: String?
    @NSManaged  var current: NSNumber?
    @NSManaged  var date: String?
    @NSManaged  var dateTime: NSDate?
    @NSManaged  var dateWithoutTime: String?
    @NSManaged  var frequency: NSNumber?
    @NSManaged  var id: NSNumber?
    @NSManaged  var postTreatmentPainLevel: NSNumber?
    @NSManaged  var preTreatmentPainLevel: NSNumber?
    @NSManaged  var treatmentArea: String?
    @NSManaged  var treatmentDuration: NSNumber?

}
