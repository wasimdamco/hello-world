//
//  Average+CoreDataClass.swift
//  EPIAL
//
//  Created by User on 23/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import Foundation
import CoreData

@objc(Average)
 class Average: NSManagedObject {

    
    class func addRecordToAverage(preTreatmentPainLevel : Double, postTreatmentPainLevel : Double, treatmentDuration : Double, Date : NSDate, type : String, frequency : Double, current : Double , treatmentArea : String){
        
    //self.addHistory(preTreatmentPainLevel, postTreatmentPainLevel: postTreatmentPainLevel, treatmentDuration: treatmentDuration, Date: Date, type: type, frequency: frequency, current: current, treatmentArea: treatmentArea)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Average",inManagedObjectContext:managedContext)
        
        let log: Average = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Average
        
        log.preTreatmentPainLevel = preTreatmentPainLevel
        log.treatmentDuration =  treatmentDuration //NSNumber(integer: treatmentDuration)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let dateString = dateFormatter.stringFromDate(Date)
        
        let dateFormatterWithoutTime = NSDateFormatter()
        dateFormatterWithoutTime.timeZone = NSTimeZone.systemTimeZone()
        dateFormatterWithoutTime.dateFormat = "MM/dd/yyyy" //format style.
        let dateWithoutTime = dateFormatterWithoutTime.stringFromDate(Date)
        
        log.dateWithoutTime = dateWithoutTime
        log.date = dateString
        log.dateTime = Date
        log.categories = type
        log.postTreatmentPainLevel = postTreatmentPainLevel
        log.frequency = NSNumber(double: frequency)
        log.current = NSNumber(double: current)
        if treatmentArea == "Select"{
            log.treatmentArea = ""
        }else{
            log.treatmentArea = treatmentArea
        }
        
        do {
            try managedContext.save()
        }
        catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }

    
    }
    
    class func fetchAverageAllHistory()-> [Average]?  {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Average" as NSString as String)
        let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetchResults: [Average]? = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Average]
            return fetchResults
        } catch _ {
        }
        return nil
        
    }
    
    class func deleteAlldataFromAverageDB(){
        
        let allData = Average.fetchAverageAllHistory()
        print(allData?.count)
        if allData?.count > 0{
            for items in allData!{
                Average.deleteAverageHistory(items)
            }
        }else{
            print("No record to delete")
        }
        
    }

    class func deleteAverageHistory(object: Average){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(object)
        do {
            try managedContext.save()
        }
        catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    
    
}
