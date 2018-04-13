//
//  LoginViewController.swift
//  EPIAL
//
//  Created by User on 15/05/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    //MARK: @IBOutlets
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldUserName: UITextField!
    
    //MARK: Properties
    var userNameWithoutWhiteSpaces : String = ""
    var passwordWithoutWhiteSpaces : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Settings textfield delegates
        textFieldPassword.delegate = self
        textFieldUserName.delegate = self
        
        // Setting the email textfield keyboard type to Emailaddress type
        textFieldUserName.keyboardType = .EmailAddress
        
       
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        // To hide the navigation bar bottom line
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
      self.navigationController?.navigationBar.shadowImage = UIImage()
    }
     
    @IBAction func loginPressed(sender: AnyObject) {
        
        hideTextfieldKeyboard()
        
        // Checking if user has entered data or not
        if textFieldUserName.text?.characters.count == 0 || textFieldPassword.text?.characters.count == 0 {
            self.showAlert("Please enter all the fields")
        }else if textFieldUserName.text?.isValidEmail() == false {
            self.showAlert("Invalid email")
        }else{
            //Removing white spaces from the string
            userNameWithoutWhiteSpaces = textFieldUserName.trimWhiteSpaces()
            passwordWithoutWhiteSpaces = textFieldPassword.trimWhiteSpaces()
            //Checking username first and then password
            if userNameWithoutWhiteSpaces.characters.count <= 0 {
            self.showAlert("Username is incorrect")
            }else if passwordWithoutWhiteSpaces.characters.count <= 0{
            self.showAlert("Password is incorrect")
            }else{
            //Handle Login here
             userLogin()
                
            }
            
        }
        
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        hideTextfieldKeyboard()
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
        let signUpVC : SignUpViewController = storyBoard.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func hideTextfieldKeyboard(){
        textFieldPassword.resignFirstResponder()
        textFieldUserName.resignFirstResponder()
    }
    
    
    func userLogin(){
    
        // get the nonce key from api
        let nonceUrl = ApiUrl.baseUrl + ApiUrl.endUrlLoginNonce
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1"]
        
        Spinner.show("Loading..")
        
         LoginManager.registerUser(nonceUrl, param: nil, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                let nonceKey = apiResponseTaken["nonce"] as! String
                print("nonce", nonceKey)
                
                // Now hit the user pass api
                
                let emailPassUrl = ApiUrl.baseUrl + ApiUrl.endUrlLoginCookie
                
                let paramerters = ["nonce": nonceKey,
                                   "email": self.textFieldUserName.text!,
                                   "password" : self.textFieldPassword.text!,
                                   "insecure" : "cool"]
                
                LoginManager.registerUser(emailPassUrl, param: paramerters, header: header, completion: { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
                    if isSuccessfullOrNot == true{
                        print(apiResponseTaken)
                        let status = apiResponseTaken["status"] as? String
                            if status == "ok"{
                                // For capturing user id
                                let userInfo = apiResponseTaken["user"] as? NSDictionary
                                let userId = userInfo!["id"] as! Int
                                print(userId)
                                NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "user_id")
                            let cookie = apiResponseTaken["cookie"] as! String
                            print("cookie" , cookie)
                            NSUserDefaults.standardUserDefaults().setObject(cookie, forKey: "cookie")
                            if NSUserDefaults.standardUserDefaults().valueForKey("cookie") != nil{
                                
                                // Delete this.. for testing only
                               // NSUserDefaults.standardUserDefaults().setObject("123456", forKey: "practitionerCode")
                                
                                NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "isFirstTime")
                                
                                PatientManager.savePractitionerCode(userId)
                                
                                LoginManager.saveModelAndSerialNumber(userId)
                                
                                SyncManager.getUserDataIfPresent({ (isCompleted) in
                                    if isCompleted == true{
                                    
                                        Spinner.hide()
                                        let storyTab = UIStoryboard(name: "Main", bundle: nil)
                                        let tabBarVc : TabViewController = storyTab.instantiateViewControllerWithIdentifier("TabViewController") as! TabViewController
                                        self.view.window?.rootViewController = tabBarVc
                                        
                                    }
                                })

                               // self.navigationController?.pushViewController(tabBarVC, animated: true)

                            }else{
                            print("Cookie Not saved")
                                Spinner.hide()
                                self.showAlert("Login again")
                            }
                        }else{
                                Spinner.hide()
                                self.showAlert("Invalid login")
                        }
                    }else{
                        Spinner.hide()
                        self.showAlert("Login again")
                    }
                })
                
            }else{
                 Spinner.hide()
                self.showAlert("Login again")
            }
        }
        
       
    }
    
    
}


extension LoginViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
