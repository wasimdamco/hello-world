//
//  SyncManager.swift
//  EPIAL
//
//  Created by User on 19/06/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit
import Alamofire

class SyncManager: NSObject {
    
    class func syncData(showLoadingIndicator : Bool){
        //fetchCompleteRecordsContainingAllFieldsFilled
        if let userData = Logger.fetchCompleteRecordsContainingAllFieldsFilled(){
            if showLoadingIndicator == true{
                saveDataApi(userData,showLoadingIndicator: true)
            }else{
                saveDataApi(userData,showLoadingIndicator: false)
            }
            
        }else{
            // No record to sync
        }
        
    }
    
    class func saveDataApi(userData : [Logger], showLoadingIndicator : Bool){
        
        var UserDataparameter = [[String : AnyObject]]()
        var effectiveFrequency : Float = 0
        var effectiveCurrent : Float = 0
        var userId  : Int = 0
        var parameter : [String : AnyObject] = [:]
        
        UserDataparameter.removeAll()
        
        // User logger entry all
        for individualData in userData{
            
            if individualData.postTreatmentPainLevel == nil &&  individualData.treatmentDuration == nil{
                
                parameter  =  ["indication_level": individualData.categories!, "pre" : individualData.preTreatmentPainLevel!.integerValue , "post" : "" , "datetime" : individualData.date! , "treatment_area" : individualData.treatmentArea! , "treatment_duration" : individualData.treatmentDuration!.integerValue , "current" : individualData.current!.floatValue , "frequency" : individualData.frequency!.floatValue]
                
            
            }else if individualData.postTreatmentPainLevel == nil ||  individualData.treatmentDuration == nil{
            
                if individualData.postTreatmentPainLevel == nil{
                    parameter  =  ["indication_level": individualData.categories!, "pre" : individualData.preTreatmentPainLevel!.integerValue , "post" : "" , "datetime" : individualData.date! , "treatment_area" : individualData.treatmentArea! , "treatment_duration" : individualData.treatmentDuration!.integerValue , "current" : individualData.current!.floatValue , "frequency" : individualData.frequency!.floatValue]
                }else{
                    parameter  =  ["indication_level": individualData.categories!, "pre" : individualData.preTreatmentPainLevel!.integerValue , "post" : individualData.postTreatmentPainLevel!.integerValue , "datetime" : individualData.date! , "treatment_area" : individualData.treatmentArea! , "treatment_duration" : "" , "current" : individualData.current!.floatValue , "frequency" : individualData.frequency!.floatValue]
                }
            
            }else{
            
            parameter  =  ["indication_level": individualData.categories!, "pre" : individualData.preTreatmentPainLevel!.integerValue , "post" : individualData.postTreatmentPainLevel!.integerValue , "datetime" : individualData.date! , "treatment_area" : individualData.treatmentArea! , "treatment_duration" : individualData.treatmentDuration!.integerValue , "current" : individualData.current!.floatValue , "frequency" : individualData.frequency!.floatValue]
                
            }
            
//            let parameter : [String : AnyObject] =  ["indication_level": individualData.categories!, "pre" : individualData.preTreatmentPainLevel!.integerValue , "post" : individualData.postTreatmentPainLevel!.integerValue , "datetime" : individualData.date! , "treatment_area" : individualData.treatmentArea! , "treatment_duration" : individualData.treatmentDuration!.integerValue , "current" : individualData.current!.floatValue , "frequency" : individualData.frequency!.floatValue]
            
            UserDataparameter.append(parameter)
        }
        
        // Most effective Frequency
        if let frequency = NSUserDefaults.standardUserDefaults().valueForKey("effectiveFrequency") as? Float{
            effectiveFrequency = frequency
            print(effectiveFrequency)
        }
        
        // Most effective current
        if let current = NSUserDefaults.standardUserDefaults().valueForKey("effectiveCurrent") as? Float{
            effectiveCurrent = current
            print(effectiveCurrent)
        }
        
        var indicationList = [String]()
        
        // Category or indication list
        if let list = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
            indicationList = list
        }else{
            indicationList = ["Pain","Anxiety","Insomnia","Depression","Enter Custom Indication", "Enter Custom Indication"]
        }
        
        // Storing user_id
        if let id = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as? Int{
            userId = id
        }
        
        
        // Creating final complete parameter
        let finalDictionary : [String : AnyObject] = ["data" : UserDataparameter, "indication_list" : indicationList, "user_id" : userId , "Most_effective_current" : effectiveCurrent , "Most_effective_frequency" : effectiveFrequency]
        
        print(finalDictionary)
        
        let syncURL =  ApiUrl.syncApiUrl
        
        if showLoadingIndicator == false{
            LoginManager.syncUserData(syncURL, param: finalDictionary) { (isSuccessfullOrNot, response, message) in
                if isSuccessfullOrNot == true{
                    print("Syncing done")
                }else{
                    print("Error in sync manager")
                }
            }
        }else{
            Spinner.show("Loading...")
            LoginManager.syncUserData(syncURL, param: finalDictionary) { (isSuccessfullOrNot, response, message) in
                Spinner.hide()
                if isSuccessfullOrNot == true{
                    print("Syncing done")
                }else{
                    print("Error in sync manager")
                }
            }
        }
     

        
    }
    
    
    //MARK: SYNCING
    class func getUserDataIfPresent(completion : (isCompleted : Bool)->Void){
        
        deleteAlldataFromDB()
        
        let getUserDataUrl = ApiUrl.userDataSync
        
        let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")?.integerValue
        print(user_id)
        //Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        let parameter : [String : AnyObject]? = ["user_id" : user_id!]
        print(parameter)
        
        LoginManager.getUserData(getUserDataUrl, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                print(apiResponseTaken)
                
                var categoryDataSource = apiResponseTaken["indication_list"] as! NSArray
                
                if categoryDataSource.count > 0{
                    NSUserDefaults.standardUserDefaults().setObject(categoryDataSource, forKey: "categoryDataSource")
                }else{
                
                    categoryDataSource = ["Pain","Anxiety","Insomnia","Depression","Enter Custom Indication", "Enter Custom Indication"]
                    NSUserDefaults.standardUserDefaults().setObject(categoryDataSource, forKey: "categoryDataSource")
                    
                }
                
                let apiMessage = apiResponseTaken["msg"] as! String
                if apiMessage == "No Data"{
                    print("No User Data")
                    completion(isCompleted: true)
                }else{
                    //Fetching user model
                    let model = apiResponseTaken["model"] as! String
                    NSUserDefaults.standardUserDefaults().setObject(model, forKey: "userDeviceModel")
                    
                    // Fetching user data
                    let userData = apiResponseTaken["data"] as! NSArray
                    print(userData)
                        for individualRecord in userData{
                        print(individualRecord)
                        let recordDictionary = individualRecord as! NSDictionary
                        let preValue = (recordDictionary["pre"] as! NSString).integerValue
                        let postValue = (recordDictionary["post"] as! NSString).integerValue
                        let treatmentDuration = (recordDictionary["treatment_duration"] as! NSString).integerValue
                        print(treatmentDuration)
                        let dateFromApi = recordDictionary["datetime"] as! String
                        let logDate = LoggerViewController.getDateTimeInNSDate(dateFromApi)
                        let indicationType = recordDictionary["indication_level"] as! String
                        let frequency = (recordDictionary["frequency"] as! NSString).doubleValue
                        let current = (recordDictionary["current"] as! NSString).doubleValue
                        let treatmentArea = recordDictionary["treatment_area"] as! String
                        
                        Logger.addHistory(preValue, postTreatmentPainLevel: postValue, treatmentDuration: treatmentDuration, Date: logDate, type: indicationType, frequency: frequency, current: current, treatmentArea: treatmentArea)
                    }
                    completion(isCompleted: true)
                }
            }
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
