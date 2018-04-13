//
//  LoginManager.swift
//  EPIAL
//
//  Created by User on 06/06/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit
import Alamofire


class LoginManager: NSObject {
    
   class func registerUser(url : String , param : [String:AnyObject]?, header : [String : String], completion : (isSuccessfullOrNot : Bool, apiResponseTaken : NSDictionary , errorMessageTaken : String)-> Void )-> Void{
        
        var parameters : [String:AnyObject]?
        
        if let params = param{
            parameters = params
        }else{
           parameters = nil
        }
    
  
    
        Alamofire.request(.POST, url, parameters: parameters, encoding: ParameterEncoding.URLEncodedInURL, headers: header).responseJSON { (response) in
            
            
            if let json = response.result.value{
                // successfull response
                print("Successfull")
                completion(isSuccessfullOrNot: true, apiResponseTaken: json as! NSDictionary, errorMessageTaken: "")
            }else{
                // Error
                print("Error")
                completion(isSuccessfullOrNot: false, apiResponseTaken: [:], errorMessageTaken: "")
            }
        }
        
        
    }
    
    class func getUserData(url : String, parameter : [String : AnyObject]?, header : [String : String], completion : (isSuccessfullOrNot : Bool, apiResponseTaken : NSDictionary, errorMessageTaken : String)-> Void)-> Void{
    
    print(parameter)
        
        Alamofire.request(.POST, url, parameters: parameter, encoding: ParameterEncoding.URL, headers: header).responseJSON { (response) in
            
            
            if let json = response.data{
                // successfull response
                print("Successfull")
                print(json)
                

                var responseData = NSDictionary()
            
                do{
                    responseData = try NSJSONSerialization.JSONObjectWithData(json  , options: NSJSONReadingOptions()) as! NSDictionary
                }catch{
                print("error in Login Manager")
                }
                
                print(responseData)
                
                completion(isSuccessfullOrNot: true, apiResponseTaken: responseData, errorMessageTaken: "")
            }else{
                // Error
                print("Error")
                completion(isSuccessfullOrNot: false, apiResponseTaken: [:], errorMessageTaken: "")
            }
        }

        
    }
    
    
    class func syncUserData(syncUrl : String, param : [String : AnyObject] , completion : (isSuccessfullOrNotValue : Bool, response : String,messageTaken : String)-> Void) -> Void{
        
        let url = NSURL(string: syncUrl)
        let mutableURLRequest = NSMutableURLRequest(URL: url!)
        mutableURLRequest.HTTPMethod = "POST"
        
        do {
            mutableURLRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(param, options: NSJSONWritingOptions())
        }catch{
            print("Error in sync api url")
        }
        
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(mutableURLRequest)
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    completion(isSuccessfullOrNotValue: true, response: String(JSON), messageTaken: "")
                }else{
                    completion(isSuccessfullOrNotValue: false, response: "", messageTaken: "")
                }
        }
        
        
    }
    
    class func saveModelAndSerialNumber(userId : Int){
        
        
        let getUserDataUrl = ApiUrl.userDataSync
        
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        let parameter : [String : AnyObject]? = ["user_id" : userId]
        print(parameter)
        
        LoginManager.getUserData(getUserDataUrl, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                
                let model = apiResponseTaken["model"] as! String
                print(model)
                NSUserDefaults.standardUserDefaults().setObject(model, forKey: "userDeviceModel")
                
                let serialNumber = apiResponseTaken["serial_number"] as! String
                print(serialNumber)
                NSUserDefaults.standardUserDefaults().setObject(serialNumber, forKey: "userSerialNumber")
                
            }
        }
        
    }
    
    class func checkForPracCode(pracCode: String, completion : (isSuccessfullOrNot : Bool, apiResponseTaken : NSDictionary , errorMessageTaken : String)-> Void )-> Void{

        let url:NSURL = NSURL(string: ApiUrl.checkPracCode)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = String(format: "prac_code=%@", pracCode)
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                completion(isSuccessfullOrNot: false, apiResponseTaken: ["Code":"Unknown error"], errorMessageTaken: "Error")
                return
            }
            
            var responseData = []
            var responseDict = NSDictionary()
            
            do{
                responseData = try NSJSONSerialization.JSONObjectWithData(data!  , options: []) as! NSArray
                responseDict = responseData[0] as! NSDictionary
                completion(isSuccessfullOrNot: true, apiResponseTaken: responseDict, errorMessageTaken: "")
            }catch{
                print("error in Login Manager")
                completion(isSuccessfullOrNot: false, apiResponseTaken: ["Code":"Unknown error"], errorMessageTaken: "Error")
            }
            
            print(responseData)
            
        }
        
        task.resume()
        
        
        
    }
    
    class func checkForPatientForPrac(pracCode: String, patientCode: String, completion : (isSuccessfullOrNot : Bool, apiResponseTaken : NSDictionary , errorMessageTaken : String)-> Void )-> Void{
        
        let url:NSURL = NSURL(string: ApiUrl.checkPatientForPrac)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = String(format: "prac_code=%@&patient_code=%@", pracCode, patientCode)
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                completion(isSuccessfullOrNot: false, apiResponseTaken: ["Code":"Unknown error"], errorMessageTaken: "Error")
                return
            }
            
            var responseData = []
            var responseDict = NSDictionary()
            
            do{
                responseData = try NSJSONSerialization.JSONObjectWithData(data!  , options: []) as! NSArray
                responseDict = responseData[0] as! NSDictionary
                completion(isSuccessfullOrNot: true, apiResponseTaken: responseDict, errorMessageTaken: "")
            }catch{
                print("error in Login Manager")
                completion(isSuccessfullOrNot: false, apiResponseTaken: ["Code":"Unknown error"], errorMessageTaken: "Error")
            }
            
            print(responseData)
            
        }
        
        task.resume()
        
        
        
    }

    
}
