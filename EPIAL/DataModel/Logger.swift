//
//  Logger.swift
//  EPIAL
//
//  Created by Juli on 18/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
	Class: Logger and NSManagedObject class which will maintain the history of all
	records. The class implements some class level functions like add history , fetchAllHistory
	and deleteHistory to perform some actions. The entity table maintain painLevel, treatmentDuration,
	date and type.
*/

class Logger: NSManagedObject {


	/**
		Class level function to add history data record in "Logger" table and save
 		the details in to database table.
		:parameter : painLevel: Int value for selected pain level
		:parameter: treatmentDuration: Int value for the duration of treatment taken.
		:parameter: Date: NSDate value for the selected date of treatment
		:parameter: type: String value for type of problem for which the other details have been logged.
	*/
    class func addHistory(preTreatmentPainLevel: Int, postTreatmentPainLevel : Int?, treatmentDuration: Int?, Date: NSDate, type: String, frequency : Double , current : Double , treatmentArea : String){
	 	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		let managedContext = appDelegate.managedObjectContext
		let entity =  NSEntityDescription.entityForName("Logger",inManagedObjectContext:managedContext)
		
  		let log: Logger = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Logger
		
		log.preTreatmentPainLevel = NSNumber(integer: preTreatmentPainLevel)
		log.treatmentDuration =  treatmentDuration //NSNumber(integer: treatmentDuration)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let dateString = dateFormatter.stringFromDate(Date)
        //let dateFormatted = dateFormatter.dateFromString(dateString)
        
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
	
	/**
		Class level function to fetch all the history records from "Logger" entity table.
		- returns: Logger instances array
	*/
	class func fetchAllHistory()-> [Logger]?  {

		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let fetchRequest = NSFetchRequest(entityName: "Logger" as NSString as String)
		let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		//let sortDescriptor = NSSortDescriptor(key: key, ascending: false)
		//fetchRequest.sortDescriptors = [sortDescriptor]
		// Execute the fetch request, and cast the results to an array of GPUserModel objects
		do {
			let fetchResults: [Logger]? = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
			return fetchResults
		} catch _ {
		}
		return nil

	}
    
    

/**
 Class level function is used to fetch complete entries from DB
 - returns: Array containing all complete entries.
 */
    class func fetchCompleteRecords()-> [Logger]?{
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Logger" as NSString as String)
        let predicate = NSPredicate(format: "treatmentDuration != nil && postTreatmentPainLevel != nil", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        do{
            let results : [Logger]? = try appdelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
            return results
        }catch{
        
        }
        return nil
    }

    //Mohit Change
   //Fetching records with all fields complete from database.
    class func fetchCompleteRecordsContainingAllFieldsFilled()-> [Logger]?{
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Logger" as NSString as String)
        let predicate = NSPredicate(format: "treatmentDuration != nil && postTreatmentPainLevel != nil && preTreatmentPainLevel != nil", argumentArray: nil)
        let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        do{
            let results : [Logger]? = try appdelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
            return results
        }catch{
            
        }
        return nil
    }
    
    class func checkIfCategoryExixtsInDB(dateInserted : NSDate , categoryInserted : String)-> [Logger]?{
     
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let newDate = dateFormatter.stringFromDate(dateInserted)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Logger" as NSString as String)
        let predicate =  NSPredicate(format:"dateWithoutTime == %@  && categories == %@"  ,newDate, categoryInserted)
        fetchRequest.predicate = predicate
        do{
            let result : [Logger]? = try appdelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
            return result
            
        }catch{
            print("Error in checkIfCategoryExixtsInDB function")
        }
        
       return nil
    }
    
    class func checkIfCompleteRecordCategoryExixtsInDB(dateInserted : NSDate , categoryInserted : String)-> [Logger]?{
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let newDate = dateFormatter.stringFromDate(dateInserted)
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Logger" as NSString as String)
        let predicate =  NSPredicate(format:"dateWithoutTime == %@  && categories == %@ && postTreatmentPainLevel != nil && treatmentDuration != nil"  ,newDate, categoryInserted)
        fetchRequest.predicate = predicate
        do{
            let result : [Logger]? = try appdelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
            return result
            
        }catch{
            print("Error in checkIfCategoryExixtsInDB function")
        }
        
        return nil
    }

    
    
    class func check(date1 : NSDate , Type : String)-> Bool{
    var status = false
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    let newDate = dateFormatter.stringFromDate(date1)
    
    let array = Logger.fetchAllHistory()
        for records in array!{
        let savedDate = dateFormatter.stringFromDate(records.dateTime!)
            if newDate == savedDate{
                if records.categories == Type{
                status = true
                }
            }
        }
        
    return status
    }
	/**
		Class level function to delete a Logger instance from the
		entity table.
		:parameter: Logger entity object to be deleted. 
	*/
	class func deleteHistory(object: Logger){
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
    
       /**
     Class level function is used to fetch records from db based on date in descending order.
     - returns: Logger instances array.
    */
    class func findRecentIncompleteRecord() -> [Logger]?{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Logger")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key : "dateTime" , ascending: false)]
        do {
            let fetchResults: [Logger]? = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Logger]
            return fetchResults
        } catch _ {
        }
        return nil
    }
    
    @available(iOS 9.0, *)
    class func deleteAllData(){
        let appDelegateCustom = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegateCustom.managedObjectContext
        let coord = appDelegateCustom.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Logger")
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            debugPrint(error)
        }
    }

    
    class func deleteAlldataFromDB(){
        
        let allData = Logger.fetchAllHistory()
        print(allData?.count)
        if allData?.count > 0{
            for items in allData!{
                Logger.deleteHistory(items)
            }
        }else{
            print("No record to delete")
        }
        
        //for testing purpose
        let data = Logger.fetchAllHistory()
        print(data)
        
    }

}
