//
//  PatientManager.swift
//  EPIAL
//
//  Created by User on 29/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PatientManager : NSObject{

    class func getPaientList(completion :(isFInished : Bool , patientCodeArray : [String] , userIDArray : [String]) -> Void) {
    
        var userIDArray = [String]()
        var patientCodeArray = [String]()
        
        let patientListURL = ApiUrl.getPatientList
        
        let practitionerCode = NSUserDefaults.standardUserDefaults().valueForKey("practitionerCode") as? String

        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        let parameter : [String : AnyObject] = ["prac_code" : practitionerCode!]
        print(parameter)
        
        LoginManager.getUserData(patientListURL, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                let apiMessage = apiResponseTaken["msg"] as! String
                if apiMessage.containsString("Data Found"){
                    let data = apiResponseTaken["data"] as? NSArray
                    for items in data!{
                        
                        let userID = items["user_id"] as? String
                        let patientCode = items["patient_code"] as? String
                        
                        userIDArray.append(userID!)
                        patientCodeArray.append(patientCode!)
  
                    }
                    
                    completion(isFInished: true, patientCodeArray: patientCodeArray, userIDArray: userIDArray)
                    
                }else{
                    print("No User Data")
                    completion(isFInished: false, patientCodeArray: patientCodeArray, userIDArray: userIDArray)
                }
            }
        }
        
        
    }




    class func savePractitionerCode(id : Int){
        
        let patientListURL = ApiUrl.getPractitionerCode
        
        let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")?.integerValue
        print(user_id)
        
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        let parameter : [String : AnyObject] = ["user_id" : id]
        print(parameter)
        
        var practitionerCode : String = ""
        
        LoginManager.getUserData(patientListURL, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                
                let apiMessage = apiResponseTaken["msg"] as! String
                if apiMessage.containsString("Data Found"){
                    let apiData = apiResponseTaken["data"] as? NSArray
                    for items in apiData!{
                        let individualDictionary = items as? NSDictionary
                        practitionerCode = individualDictionary!["practitioner_code"] as! String
                        print(practitionerCode)
                        NSUserDefaults.standardUserDefaults().setObject(practitionerCode, forKey: "practitionerCode")
                        return
                    }
                    
                }else{
                    practitionerCode = ""
                    NSUserDefaults.standardUserDefaults().setObject(practitionerCode, forKey: "practitionerCode")
                }
            }
        }
        
         NSUserDefaults.standardUserDefaults().setObject(practitionerCode, forKey: "practitionerCode")
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
    
    class func getAllUsersIndicationdata(categoryData : String, completion : (averageTreatmentDuration : String, percentImprovementAllUsers : String) -> Void){
        
        let allUsersURL = ApiUrl.percentImprovementAllUsers
        print(allUsersURL)

        let parameter : [String : AnyObject] = ["indication_type" : categoryData]
        print(parameter)

        
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        LoginManager.getUserData(allUsersURL, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                let apiMessage = apiResponseTaken
                print(" Indication Type : \(categoryData) and its data : \(apiMessage)")
                completion(averageTreatmentDuration: (apiMessage["average_of_traetment_duration"] as? String) ?? "", percentImprovementAllUsers: (apiMessage["percent_improvement"] as? String) ?? "")
            }
        }

        
    }
    
}
