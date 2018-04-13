//
//  SignUpViewController.swift
//  EPIAL
//
//  Created by User on 19/05/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController{

    //MARK: @IBOutlets
    @IBOutlet weak var allView: UIView!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var medicationTextField: UITextField!
    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    // username textfieldis the email textfield in UI
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var modelPicker: ButtonExtender!
    @IBOutlet weak var agePicker: ButtonExtender!
    @IBOutlet weak var ethnicityPicker: ButtonExtender!
    @IBOutlet weak var militaryBackgroundSwitch: UISwitch!
    @IBOutlet weak var agreeTermsAndCondition: UIButton!
    @IBOutlet weak var genderPicker: ButtonExtender!
    @IBOutlet weak var practitionerCodeTextField: UITextField!
    
    //MARK: Properties
    let pickerView = UIPickerView()
    //The done view  of the picker button
    let doneButtonView = UIView()
    var pickerViewDataSource = NSMutableArray()
    var pickerViewSelectedValue : String = ""
    var militaryBackgroundSwitchValue : String = "No"
    // setting agree to terms and condition value to false as default setting
    var agreeToTermsAndConditionValue : Bool = false
    var activeField: UITextField?
    var allViewFrame : CGRect?
    var edgeInsets : UIRectEdge?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding action to the UISwitch.
        militaryBackgroundSwitch.addTarget(self, action: #selector(self.switchStateChanged(_:)), forControlEvents: .ValueChanged)
        // Setting textfield delegate to self
        self.setTextfieldDelegateToSelf(userNameTextField,serialNumberTextField,passwordTextField,medicationTextField,practitionerCodeTextField)
    
        //setting emailtextfield keyboard to email adrress type
        userNameTextField.keyboardType = UIKeyboardType.EmailAddress

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Setting military background switch to off as default setting
        militaryBackgroundSwitch.setOn(false, animated: true)
        // Setting agrre terms and conditions default image
        agreeTermsAndCondition.setImage(UIImage(named : "noCheckImage"), forState: .Normal)
        
        //UIApplication.sharedApplication().statusBarHidden = false
        print(scrollView.contentInset)
        enableDisableScrolling()
        
        //self.navigationController?.navigationBarHidden = true
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //scrollView.frame = CGRectMake(0, 64, scrollView.frame.width, scrollView.frame.height)
        scrollView.contentSize = CGSizeMake(self.view.frame.width, allView.frame.height + 100)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func enableDisableScrolling(){
        let deviceModel = UIDevice.currentDevice().modelName
        if deviceModel.containsString("5"){
            scrollView.scrollEnabled = true
        }else{
            scrollView.scrollEnabled = false
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    @IBAction func productWarrantyPressed(sender: UIButton) {
        let story = UIStoryboard(name: "Login", bundle: nil)
        let pdfVC : TermsAndConditionsPDFViewController = story.instantiateViewControllerWithIdentifier("TermsAndConditionsPDFViewController") as! TermsAndConditionsPDFViewController
        pdfVC.urltaken = "http://www.alpha-stim.com/product-registration/"
        self.navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    func addPractitionerValidations(){
        
//        if modelPicker.titleLabel?.text?.removeWhiteSpacesFromString().characters.count <= 0 {
//            self.showAlert("Please select the model")
//        }else if serialNumberTextField.text?.removeWhiteSpacesFromString().characters.count <= 0{
//            self.showAlert("Please enter the serial number")
//        }else{
//            //registerUser()
//            registerUser("doctor", doctorCodeForPatient: "", patientCode: "", practitionerCode: practitionerCodeTextField.text! ?? "")
//        }
        
        if checkIfTextfieldsCharactersAreNull(userNameTextField.text!,passwordTextField.text!,serialNumberTextField.text!) || checkNullStringForButtons(modelPicker){
            self.showAlert("Please fill all the details") // checking if all fields are filled or not
        }else if checkIfTextfieldsCharactersAreNull(userNameTextField.text!.removeWhiteSpacesFromString(),passwordTextField.text!.removeWhiteSpacesFromString(),serialNumberTextField.text!.removeWhiteSpacesFromString()){
            showAlert("Please enter valid details") // check if the user has filled only white spaces in the text fields
        }else if userNameTextField.text?.isValidEmail() == false{
            self.showAlert("Invalid email") // checking for invald or not
        }else if checkSerialNumberTextField() == true{ // check for serial number validations
            
            // checking for serial number character validation
            if serialNumberTextField.text?.characters.count == 6 {
                
                // Write code if you want to put validations for agree to terms and conditions
                
                let addPC = practitionerCodeTextField.text!
                //before register practitioner, check if already exists
                
                if  self.compareTwoImages("check", comparingImage: self.agreeTermsAndCondition.imageView!.image!) == true{
                    pCodeAvailability(addPC)
                }else{
                    
                    self.showAlert("Please agree with terms and conditions")
                }

                
            }else{
                showAlert("Serial number must be of 6 digits")
            }
        }

    }
    
    func pCodeAvailability(pCode: String) {
        
        Spinner.show("Loading..")
        LoginManager.checkForPracCode(pCode) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            //
            if isSuccessfullOrNot {
                
                let parse = apiResponseTaken
                let msg = parse.valueForKey("msg") as! String
                if msg == "Already Exists" {
                    dispatch_async(dispatch_get_main_queue(),{
                        Spinner.hide()
                        self.showAlert("Practitioner Code not available, please enter a new Practitioner Code")
                        
                    })
                    
                    
                }
                else {
                    
                    
                    // check if user has agreed to terms and conditions
                    
                    self.registerUser("doctor", doctorCodeForPatient: "", patientCode: "", practitionerCode: pCode ?? "")
                    NSUserDefaults.standardUserDefaults().setObject(pCode, forKey: "practitionerCode")

                    
                    
                }
                
            }
            else {
                Spinner.hide()
                dispatch_async(dispatch_get_main_queue(),{
                    
                    self.showAlert("Unkown error")
                    
                })
                
            }
        }

        
    }
    
    
    func addAllValidations(){
        
        if checkIfTextfieldsCharactersAreNull(userNameTextField.text!,medicationTextField.text!,passwordTextField.text!,serialNumberTextField.text!) || checkNullStringForButtons(modelPicker,agePicker,ethnicityPicker,genderPicker){
            self.showAlert("Please fill all the details") // checking if all fields are filled or not
        }else if checkIfTextfieldsCharactersAreNull(userNameTextField.text!.removeWhiteSpacesFromString(),medicationTextField.text!.removeWhiteSpacesFromString(),passwordTextField.text!.removeWhiteSpacesFromString(),serialNumberTextField.text!.removeWhiteSpacesFromString()){
            showAlert("Please enter valid details") // check if the user has filled only white spaces in the text fields
        }else if userNameTextField.text?.isValidEmail() == false{
            self.showAlert("Invalid email") // checking for invald or not
        }else if checkSerialNumberTextField() == true{ // check for serial number validations
            
            // checking for serial number character validation
            if serialNumberTextField.text?.characters.count == 6 {
                
                // check if user has agreed to terms and conditions
                
                if  compareTwoImages("check", comparingImage: agreeTermsAndCondition.imageView!.image!) == true{
                    //registerUser() // hit the register user api
                    registerUser("user", doctorCodeForPatient: "", patientCode: "", practitionerCode: "")
                }else{
                    self.showAlert("Please agree with terms and conditions")
                }
                
            }else{
                showAlert("Serial number must be of 6 digits")
            }
        }
        
    }

    @IBAction func resgiterPressed(sender: UIButton) {
        
       //use removeFirstTwoSpacesFromString() from from string extension to remove first two spaces from the buttons string when sending data to the server
        
        // Validation of the practitioner version of the app.
        if practitionerCodeTextField.text?.removeWhiteSpacesFromString().characters.count > 0{
            
            let pCode = practitionerCodeTextField.text!
            
            if pCode.characters.count<3{
                self.showAlert("Practitioner code must greater than two characters")
            }
            else
            {
                let validateCode = (pCode as NSString).substringToIndex(2)
                if validateCode != "PC" {
                    self.showAlert("Practitioner code must begin with PC")
                }
                else {
                    addPractitionerValidations()
                }
            }
           
        }else{
            addAllValidations()
        }
    
    }
    
    func compareTwoImages(emptyImageName : String, comparingImage : UIImage)-> Bool{
        
        var status : Bool = false
        
        if let emptyImage = UIImage(named: emptyImageName) {
            let emptyData = UIImagePNGRepresentation(emptyImage)
            let compareImageData = UIImagePNGRepresentation(comparingImage)
            
            if let empty = emptyData,compareTo = compareImageData {
                if empty.isEqualToData(compareTo) {
                    // Empty image is the same as image1.image
                    status =  true
                } else {
                    // Empty image is not equal to image1.image
                    status = false
                }
            }
        }
        
        return status
    }
    
    // To show terms and conditions pdf
    @IBAction func agreeWithTermsAndConditionsPdfView(sender: UIButton) {
        
        let story = UIStoryboard(name: "Login", bundle: nil)
        let pdfVC : TermsAndConditionsPDFViewController = story.instantiateViewControllerWithIdentifier("TermsAndConditionsPDFViewController") as! TermsAndConditionsPDFViewController
        pdfVC.urltaken = "http://www.alpha-stim.com/app-terms/"
        self.navigationController?.pushViewController(pdfVC, animated: true)
            
    }
    
    func checkSerialNumberTextField()-> Bool{
        
        if serialNumberTextField.text?.characters.first == "4" || serialNumberTextField.text?.characters.first == "5" {
            return true
        }else{
            self.showAlert("Serial number must start with 4 or 5")
            return false
        }
    }
    
    
    func registerUser(userType : String, doctorCodeForPatient : String, patientCode : String , practitionerCode : String){
        let nonceUrl = ApiUrl.baseUrl + ApiUrl.endUrlNonce
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1"]
        
         Spinner.show("Loading..")

        // Hit api to get the nonce
        LoginManager.registerUser(nonceUrl, param: nil, header: header) { (isSuccessfull, apiResponse, errorMessageTaken) in
            if isSuccessfull == true{
                print(apiResponse)
                let nonce = apiResponse["nonce"] as! String
                print(nonce)
            
                // After getting the nonce hit api to send the email and passoword
                let emailAndPassUrl = ApiUrl.baseUrl + ApiUrl.endUrlEmailAndPass
                
                
                //Previous code
                let usernameAndPasswordParameters : [String : String] = ["nonce": nonce, "username" : self.userNameTextField.text!, "email" : self.userNameTextField.text!, "display_name" : self.userNameTextField.text! , "user_pass" : self.passwordTextField.text! , "insecure" : "cool"]
                
                LoginManager.registerUser(emailAndPassUrl, param: usernameAndPasswordParameters, header: header, completion: { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
                    
                    if isSuccessfull == true{
                        print(apiResponseTaken)
                        
                        let status = apiResponseTaken["status"] as! String
                        
                        if status == "error"{
                            Spinner.hide()
                            self.showAlert("Username already exists")
                        }else{
                            
                            let userId = apiResponseTaken["user_id"] as! Int
                            print(userId)
                            
                            //Storing the userId
                            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "user_id")
                            
                            let cookie = apiResponseTaken["cookie"] as! String
                            // After getting the cookie send all the data to the register user api
                            // Hit the api to send the full user data
                            
                            NSUserDefaults.standardUserDefaults().setObject(cookie, forKey: "cookie")
                            let ageWithoutFirstTwoSpaces  = self.agePicker.titleLabel?.text?.removeFirstTwoSpacesFromString()
                            let ageNumberOnly = ageWithoutFirstTwoSpaces?.getStringsFirstComponent()
                            print(ageNumberOnly)
                            
                            var ageTaken : Int = 0
                            var gender : String = ""
                            var medication : String = ""
                            var ethnicity : String = ""
                            
                            if ageNumberOnly == nil{
                                ageTaken = 0
                            }else{
                                ageTaken = Int(ageNumberOnly!)!
                            }
                            
                            
                            if self.genderPicker.titleLabel?.text?.removeFirstTwoSpacesFromString() != nil{
                                gender = (self.genderPicker.titleLabel?.text?.removeFirstTwoSpacesFromString())!
                            }
                            
                            if self.ethnicityPicker.titleLabel?.text?.removeFirstTwoSpacesFromString() != nil{
                                ethnicity =  (self.ethnicityPicker.titleLabel?.text?.removeFirstTwoSpacesFromString())!
                            }
                            
                            if self.medicationTextField.text != nil{
                                medication =  self.medicationTextField.text!
                            }
                            
                            
                            let completeDetailUrl = ApiUrl.baseUrl + ApiUrl.endUrlCompleteDetails
                            let completeParameters :[String : AnyObject] = ["cookie": cookie,
                                "model":(self.modelPicker.titleLabel?.text?.removeFirstTwoSpacesFromString())!,
                                "serial_number":self.serialNumberTextField.text!,
                                "age": ageTaken,
                                "gender" : gender,
                                "military_background" : self.militaryBackgroundSwitchValue ,
                                "medication" : medication ,
                                "ethnicity" : ethnicity ,
                                "insecure" : "cool",
                                "usertype" : userType,
                                "practitioner_code": practitionerCode,
                                "patient_code": patientCode,
                                "doctor_code_for_patient": doctorCodeForPatient
                            ]
                            print(completeParameters)
                            LoginManager.registerUser(completeDetailUrl, param: completeParameters, header: header, completion: { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
                                if isSuccessfull == true{
                                    
                                    let status = apiResponseTaken["status"] as! String
                                    if status == "ok"{
                                       // self.showAlert("\(self.userNameTextField.text!) succesfully registered")
                                        if NSUserDefaults.standardUserDefaults().valueForKey("cookie") != nil{
                                            Spinner.hide()
                                            
                                             NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "isFirstTime")
                                            NSUserDefaults.standardUserDefaults().setObject((self.modelPicker.titleLabel?.text?.removeFirstTwoSpacesFromString())!, forKey: "userDeviceModel")
                                            NSUserDefaults.standardUserDefaults().setObject(self.serialNumberTextField.text!, forKey: "userSerialNumber")
                                            
                                            let idTaken = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! Int
                                            print(idTaken)
                                            PatientManager.savePractitionerCode(idTaken)
                                            
                                            self.takeToTabViewController()
                                        }else{
                                            Spinner.hide()
                                            print("Cookie Not saved")
                                        }

                                    }else{
                                        Spinner.hide()
                                        self.showAlert("Resgister aagain")
                                    }
                                }else{
                                    Spinner.hide()
                                    self.showAlert("Resgister aagain")
                                }
                            })
                            
                        }
                    }else{
                        Spinner.hide()
                        self.showAlert("Register again")
                    }
                    
                })
                
                
            }else{
                 Spinner.hide()
                self.showAlert("Register again")
            }
        }
       
    }
    
    func switchStateChanged(switchTaken : UISwitch){
        if switchTaken.on{
            militaryBackgroundSwitchValue = "Yes"
        }else{
            militaryBackgroundSwitchValue = "No"
        }
    }
  
    func checkIfTextfieldsCharactersAreNull(textFieldTexts : String...)-> Bool{
        var status = false
        for text in textFieldTexts{
            if text.characters.count <= 0{
                status = true
                return status
            }
        }
        return status
    }
    
    func setTextfieldDelegateToSelf(textFieldsTaken : UITextField...){
        for fields in textFieldsTaken{
            fields.delegate = self
        }
    }
    
    func setTextFieldToFirstResponder(textFields : UITextField...){
        for fields in textFields{
            fields.resignFirstResponder()
        }
    }
    
    func checkNullStringForButtons(buttons : UIButton...)-> Bool{
        var status = false
        for individualButton in buttons{
            if individualButton.titleLabel?.text == nil{
                status = true
                return status
            }
        }
        return status
    }
    
    //MARK: Private function
    func createPickerView(buttonTaken : UIButton , buttonTag : Int){
        
        // Creating and setting picker view delegate and datasource.
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        pickerView.frame = CGRectMake(0, (self.view.frame.height - 200), self.view.frame.width, 200)
        pickerView.layer.borderWidth = 2.0
        pickerView.layer.borderColor = UIColor.whiteColor().CGColor
        setPickerViewBackroundColor(pickerView, colortaken: UIColor.whiteColor())
        self.view.addSubview(pickerView)
        
        // Creating view which will have the done button
        doneButtonView.frame = CGRectMake(0, (self.view.frame.height - 230), self.view.frame.width, 30)
        doneButtonView.layer.borderWidth = 2.0
        doneButtonView.layer.borderColor = UIColor.whiteColor().CGColor
        setPickerViewBackroundColor(doneButtonView, colortaken: nil)
        self.view.addSubview(doneButtonView)
        
        // Creating the done button
        let doneButton = UIButton()
        doneButton.frame = CGRectMake((doneButtonView.frame.maxX - 50), 0, 50, doneButtonView.frame.height)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        doneButton.tag = buttonTag
        if #available(iOS 10.0, *) {
            doneButton.backgroundColor = UIColor(displayP3Red: 107/225, green: 129/225, blue: 132/225, alpha: 1.0)
        } else {
            doneButton.backgroundColor = UIColor(colorLiteralRed: 107/225, green: 129/225, blue: 132/225, alpha: 1.0)
        }
        doneButton.addTarget(self, action: #selector(self.doneButtonPressed(_:)), forControlEvents: .TouchUpInside)
        doneButtonView.addSubview(doneButton)
       
            }
    
    @IBAction func modelPickerPressed(sender: UIButton) {
        self.setTextFieldToFirstResponder(userNameTextField,serialNumberTextField,passwordTextField,medicationTextField)
        setUpPickerViewForbutton(["Alpha-Stim M", "Alpha-Stim AID"], tagTaken: 20, buttonTaken: sender)
    }
    
    @IBAction func termsAndConditionPressed(sender: UIButton) {
        if agreeTermsAndCondition.imageForState(.Normal) == UIImage(named : "noCheckImage"){
            agreeTermsAndCondition.setImage(UIImage(named : "check"), forState: .Normal)
            agreeToTermsAndConditionValue = true
        }else{
            agreeTermsAndCondition.setImage(UIImage(named : "noCheckImage"), forState: .Normal)
            agreeToTermsAndConditionValue = false
        }
    }
    
    @IBAction func agePickerPressed(sender: UIButton) {
        self.setTextFieldToFirstResponder(userNameTextField,serialNumberTextField,passwordTextField,medicationTextField, practitionerCodeTextField)
        self.setUpPickerViewForbutton(self.createAgeDataSource(), tagTaken: 30, buttonTaken: sender)
    }

    @IBAction func ethnicityPickerPressed(sender: UIButton) {
        self.setTextFieldToFirstResponder(userNameTextField,serialNumberTextField,passwordTextField,medicationTextField)
        setUpPickerViewForbutton(["White", "Black or African","Asian" , "Native American", "Native Hawaiian", "Hispanic or Latino" , "Others"], tagTaken: 40, buttonTaken: sender)
    }
    
    @IBAction func genderPickerPressed(sender: UIButton) {
        self.setTextFieldToFirstResponder(userNameTextField,serialNumberTextField,passwordTextField,medicationTextField)
        setUpPickerViewForbutton(["Male", "Female"], tagTaken: 50, buttonTaken: sender)
    }
    
    
    
    func doneButtonPressed(sender : UIButton){
        
        self.removePickerView()
        
        switch sender.tag{
        case 20 :  modelPicker.setTitle(pickerViewSelectedValue, forState: .Normal)
        case 30 :  agePicker.setTitle(pickerViewSelectedValue, forState: .Normal)
        case 40 :  ethnicityPicker.setTitle(pickerViewSelectedValue, forState: .Normal)
        case 50 :  genderPicker.setTitle(pickerViewSelectedValue, forState: .Normal)
        default :  print("No category found")
        }
    
    }
    
    func removePickerView(){
        pickerView.removeFromSuperview()
        doneButtonView.removeFromSuperview()
    }
    
    func createAgeDataSource()-> NSMutableArray{
        let ageArray = NSMutableArray()
        for i in 1...150{
            if i == 1{
                ageArray.addObject(String(i) + " year")
            }else{
                 ageArray.addObject(String(i) + " years")
            }
           
        }
        return ageArray
    }
    
    func setPickerViewBackroundColor(viewtaken : UIView, colortaken : UIColor?){
        
        if colortaken == nil{
            if #available(iOS 10.0, *) {
                viewtaken.backgroundColor = UIColor(displayP3Red: 107/225, green: 129/225, blue: 132/225, alpha: 1.0)
            } else {
                viewtaken.backgroundColor = UIColor(colorLiteralRed: 107/225, green: 129/225, blue: 132/225, alpha: 1.0)
            }
        }else{
            viewtaken.backgroundColor = colortaken
        }
        
        

    }
    
    func setUpPickerViewForbutton(dataSource : NSMutableArray , tagTaken : Int , buttonTaken : UIButton){
        pickerViewDataSource.removeAllObjects()
        pickerViewDataSource = dataSource
        createPickerView(buttonTaken, buttonTag: tagTaken)
        pickerViewSelectedValue =  "  \(pickerViewDataSource[0] as! String)"
    }
    
}

extension SignUpViewController : UIPickerViewDelegate , UIPickerViewDataSource{

    // Number of cloumns to display in picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
    return 1
    }
    
    // Number of rows in each component
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
    return pickerViewDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
    return pickerViewDataSource[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        pickerViewSelectedValue = "  \(pickerViewDataSource[row] as! String)"
    }
    // For setting the color of the pickerview data
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewDataSource[row]
        let myTitle = NSAttributedString(string: titleData as! String, attributes: [NSForegroundColorAttributeName : UIColor.blackColor()])
        return myTitle
    }
}

extension SignUpViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        self.removePickerView()
    }
    
    func textFieldDidEndEditing(textField: UITextField!)
    {
        activeField = nil
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == serialNumberTextField{
            let aSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            return string == numberFiltered
        }else{
            return true
        }
        
        
    }
}
