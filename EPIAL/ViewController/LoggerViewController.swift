//
//  LoggerViewController.swift
//  EPIAL
//
//  Created by Juli on 17/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import CoreData

enum InputType {
    case treatmentDuration
    case preTreatmentLevel
    case postTreatmentLevel
    case dateTime
    case type
    case frequencyLevel
    case currentLevel
}


/**
 Class: LoggerViewController is the controller class that implements the functions to record all
 the required information about Electomedical device outputs. The class has sections from which the
 actual machine outputs or readings can be recorded. Like Pain level, treatmentDuration , type etc.
 All the inputs messures are predefind and user need to choose any one from them. This is implemented
 via UIPickerView and UiDatePicker. The views are created at separate classes name EPPickerView and EPDatePickerView
 . The classes are instantiated via openDataPickerWithDataSource function by passing the array of dataSource.
 Controller also implements the delegate functions of these views class. so on selection proper value action is taken on the controller.
 */

class LoggerViewController: UIViewController,PickerSelectionDelegate,DatePickerSelectionDelegate,takeTableViewData, MFMailComposeViewControllerDelegate, HumanBodyViewControllerProtocol {
    
    @IBOutlet weak var buttonView: UIView!
    
    var isHandlingIncompleteEntry = false
    
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var preTreatmentButton: UIButton!
    @IBOutlet weak var postTreatmentButton: UIButton!
    
    @IBOutlet weak var selectAddPatientButton: UIButton!
    @IBOutlet weak var patientTitleLabel: UILabel!
    @IBOutlet weak var patientDropDownArrow: UIImageView!
    
    @IBOutlet weak var frequencyButton: UIButton!
    @IBOutlet weak var currentButton: UIButton!
    
    
    @IBOutlet weak var effectiveValuesView: UIView!
    @IBOutlet weak var effectiveCurrentLabel: UILabel!
    @IBOutlet weak var effectiveFrequencyLabel: UILabel!
    @IBOutlet weak var treatmentButton: UIButton!
    @IBOutlet weak var dateTimeButton: UIButton!
    @IBOutlet weak var typesButton: UIButton!
    var historyView: EPHistoryTableView?
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    var recordObjectID : NSManagedObjectID?
    
    // For managing custom indication
    var typesOfDiseasesDataSource = ["Pain","Anxiety","Insomnia","Depression","Enter Custom Indication", "Enter Custom Indication"]

    var typesRowSelected : Int?
    
    @IBOutlet weak var treatmentAreaButton: UIButton!
    var yAxisRange = 15
    var yDataSourceValues: [String] = [String]()
    var logDate = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()
        addHistoryTableView(CGRectMake(0, 0 , tableContainer.frame.size.width, tableContainer.frame.size.height))
        self.setupView()
        var patientCode = (NSUserDefaults.standardUserDefaults().objectForKey("patient_code") as? String!)!
        self.patientTitleLabel?.text? = "Patient: " + "\(patientCode)"
        var pracCode = (NSUserDefaults.standardUserDefaults().objectForKey("practitionerCode") as? String!)!
        if (pracCode.isEmpty || (pracCode.characters.count == 0)){
            self.effectiveValuesView.hidden = true
        }
        else {
            self.effectiveFrequencyLabel.text = "  Practitioner Code: "+"\(pracCode)"
            historyView?.historyTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 27, right: 0)
        }
        
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("View will disappear , Logger")
        
//        if let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String{
//            if userDeviceModel == "Alpha-Stim AID"{
//                NSUserDefaults.standardUserDefaults().setObject(["Anxiety","Insomnia","Depression","Enter Custom Indication", "Enter Custom Indication"], forKey: "categoryDataSource")
//            }else{
//                NSUserDefaults.standardUserDefaults().setObject(typesOfDiseasesDataSource, forKey: "categoryDataSource")
//            }
//        }else{
//            NSUserDefaults.standardUserDefaults().setObject(typesOfDiseasesDataSource, forKey: "categoryDataSource")
//        }
        
        //Mohit change
        NSUserDefaults.standardUserDefaults().setObject(typesOfDiseasesDataSource, forKey: "categoryDataSource")
        print(typesOfDiseasesDataSource)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoggerViewController.notificationRecieved(_:)), name: "treatmentAreaValue", object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("View did disappear , Logger")
    }
    
    func managetabBarItem(){
        if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items as! AnyObject as? NSArray,tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
            tabBarItem.enabled = true
        }
    }

    
    func navigateToPatientAndSelection(){
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let patientSelectionAndAdditionVC = story.instantiateViewControllerWithIdentifier("PatientSelectionAndAdditionViewController") as! PatientSelectionAndAdditionViewController
        self.navigationController?.pushViewController(patientSelectionAndAdditionVC, animated: true)
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        print("View will appear , Logger")
        self.tabBarController?.tabBar.items?[1].title = NSLocalizedString("Progress Log", comment: "comment")
                
        //Now written in appdelegate
        //NSUserDefaults.standardUserDefaults().setObject("yes", forKey: "isPractitionerPresent")
        self.tabBarController?.tabBar.items?[1].title = NSLocalizedString("Progress Log", comment: "comment")
        

        
         self.removePickerSubView()
        
       //managetabBarItem()
        
        if let pracCode = NSUserDefaults.standardUserDefaults().valueForKey("practitionerCode") as? String{
            
            if pracCode != "" {
                 managePatientButton(false)
                if let firstTime = NSUserDefaults.standardUserDefaults().valueForKey("isFirstTime") as? String{
                    
                    if firstTime == "yes"{
                        if let dataSource = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
                            self.typesOfDiseasesDataSource = dataSource
                        }
                        navigateToPatientAndSelection()
                        NSUserDefaults.standardUserDefaults().setObject("no", forKey: "isFirstTime")
                    }else{
                        appUserFLow()
                    }
                    
                }else{
                    appUserFLow()
                }
            }else{
                managePatientButton(true)
                appUserFLow()
            }
            
        }else{
            managePatientButton(true)

            // if no practitioner code it means user is not doctor, then make the app follow the userFlow
            appUserFLow()
            
        }
        
        
        // Manage treatment area text.
    }
    
    func managePatientButton(isHidden : Bool){
        if isHidden == true{
            patientTitleLabel.hidden = true
            selectAddPatientButton.hidden = true
            patientDropDownArrow.hidden = true
        }else{
            patientTitleLabel.hidden = false
            selectAddPatientButton.hidden = false
            patientDropDownArrow.hidden = false
        }
    }
    
    func appUserFLow(){
        
        
        //self.removePickerSubView()
        self.navigationController?.navigationBarHidden = false
        self.historyView?.refreshView()
        //self.showrecentIncompleteEntry()
        
        if let comingFromBodyPartsScreenValue = NSUserDefaults.standardUserDefaults().valueForKey("isNavigatingFromBothBodyPartsScreen") as? String{
            if comingFromBodyPartsScreenValue == "false"{
                self.resetValues()
                self.showrecentIncompleteEntry()
                print(typesButton.titleLabel?.text)
                if typesButton.titleLabel?.text == "Pain"{
                    self.resetTreatmentAreaButton("Select")
                }else{
                    self.resetTreatmentAreaButton("Brain")
                }
                
            }else{
                NSUserDefaults.standardUserDefaults().setObject("false", forKey: "isNavigatingFromBothBodyPartsScreen")
            }
        }else{
            self.resetValues()
            self.showrecentIncompleteEntry()
        }
        
        
        //self.manageEffectiveValues()
        
        
        if let dataSource = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
            self.typesOfDiseasesDataSource = dataSource
        }
        
        //createCategorydataSource()

    }
    
    
    func createCategorydataSource(){
    
    Spinner.show("Loading...")
        var categoryData : [String] = ["Pain","Anxiety","Insomnia","Depression","Enter Custom Indication", "Enter Custom Indication"]
        
        let dataInDB = Logger.fetchAllHistory()
        if dataInDB?.count > 0{
            for records in dataInDB!{
                let category = records.categories
                if categoryData.contains(category!){
                    // do nothing
                }else{
                    categoryData.append(category!)
                }
            }
            
        }
        
        if categoryData.count > 6{
            categoryData = recursiveThing(categoryData)
            if categoryData.count == 5{
                categoryData.append("Enter Custom Indication")
            }
        }
        
        print(categoryData)
        
        self.typesOfDiseasesDataSource = categoryData
        NSUserDefaults.standardUserDefaults().setObject(categoryData, forKey: "categoryDataSource")
    Spinner.hide()
    }
    
    func recursiveThing(dataSource : [String]) -> [String]{
        
        
        var finalCategoryArray = [String]()
        
        for item in dataSource{
            if item == "Enter Custom Indication"{
                // do nothing
            }else{
                finalCategoryArray.append(item)
            }
            
        }
    
        
        return finalCategoryArray
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    func notificationRecieved(notification : NSNotification){
        let value = notification.object as? UIButton
        print(value)
        treatmentAreaButton.setTitle(value?.titleLabel?.text, forState: .Normal)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func manageEffectiveValues(){
        
        self.effectiveValuesView.hidden = true
        
        var currentValue : String?
        var frequencyValue : String?
    
        if let currentValueFromFunction = self.getMostEffectiveCurrent(){
            currentValue = currentValueFromFunction
            print(currentValue!)
            effectiveCurrentLabel.text = "Most Effective Current: \(currentValue!) µA"
            NSUserDefaults.standardUserDefaults().setObject(Float(currentValueFromFunction), forKey: "effectiveCurrent")
        }
        
        if let frequencyValueFromFunction = self.getMostEffectiveFrequency(){
            frequencyValue = frequencyValueFromFunction
            effectiveFrequencyLabel.text = "Most Effective Frequency: \(frequencyValue!) Hz"
            NSUserDefaults.standardUserDefaults().setObject(Float(frequencyValueFromFunction), forKey: "effectiveFrequency")
        }
        
        if currentValue != nil || frequencyValue != nil{
            self.effectiveValuesView.hidden = true
        }else{
            self.effectiveValuesView.hidden = true
        }
        
        
        
    }
    
    /**
     Function to set the background color of Submit button and reset button.
     */
    func setupView(){
            for points in 0...yAxisRange{
            yDataSourceValues.append(String(points*10) + " mins")
        }
        
//        let layer = CALayer()
//        
//        layer.backgroundColor = UIColor(red: 142/265.0, green: 142/265.0, blue: 142/265.0, alpha: 1.0).CGColor
//        
//        layer.frame = CGRectMake(buttonView.frame.origin.x, buttonView.frame.origin.y - 5, buttonView.frame.size.width, 5)
//        
//        buttonView.layer.addSublayer(layer)
        
        submitButton.setBackgroundImage(UIImage(named: "Submit_button_strip")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forState: .Normal)
        
        resetButton.setBackgroundImage(UIImage(named: "Reset_button_strip")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forState: .Normal)
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Function is called when Treatment Duration button is pressed.
     */
    @IBAction func treatmentDurationPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        openDataPickerWithDataSource(yDataSourceValues, input: InputType.treatmentDuration, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: "Select treatment duration", previousValue: (treatmentButton.titleLabel?.text)!)
    }
    
    /**
     Function is called when Pre-Treatment Level button is pressed.
     */
    @IBAction func preTreatmentLevelPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true

        switch typesButton.titleLabel!.text! {
        case "Pain":
            changePickerDataSource(["0 No Pain","1","2","3","4","5","6","7", "8", "9", "10 Worst Pain I've Ever Had"],treatmentLevelType: .preTreatmentLevel, pickerTitle: "Select pre pain level", previousValueTaken: (preTreatmentButton.titleLabel?.text)!)
            
        case "Anxiety":
             changePickerDataSource(["0 Not Anxious","1","2","3","4","5","6","7", "8", "9", "10 Worst Anxiety I've Ever Had"], treatmentLevelType: .preTreatmentLevel, pickerTitle: "Select pre pain level", previousValueTaken:  (preTreatmentButton.titleLabel?.text)!)
            
        case "Insomnia":
             changePickerDataSource(["0 Best Sleep","1","2","3","4","5","6","7", "8", "9", "10 Worst Sleep I've Ever Had"], treatmentLevelType: .preTreatmentLevel, pickerTitle: "Select pre pain level", previousValueTaken: (preTreatmentButton.titleLabel?.text)!)
            
        case "Depression":
            changePickerDataSource(["0 Not Depressed","1","2","3","4","5","6","7", "8", "9", "10 Worst Depression I've Ever Had"], treatmentLevelType: .preTreatmentLevel, pickerTitle: "Select pre pain level", previousValueTaken: (preTreatmentButton.titleLabel?.text)!)

        default:
            
            let worstLabeltext = "10 Worst " + (typesButton.titleLabel?.text)! + " I've Ever Had"

            changePickerDataSource(["0 Best Relief I've Ever Had","1","2","3","4","5","6","7", "8", "9", worstLabeltext], treatmentLevelType: .preTreatmentLevel, pickerTitle: "Select pre pain level", previousValueTaken: (preTreatmentButton.titleLabel?.text)!)
        }
        
    }
    
    
    
    /**
     Function is called when Post-Treatment Level button is pressed.
     */
    
    @IBAction func postTreatmentLevelPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true

        switch typesButton.titleLabel!.text! {
        case "Pain":
             changePickerDataSource(["0 No Pain","1","2","3","4","5","6","7", "8", "9", "10 Worst Pain I've Ever Had"],treatmentLevelType: .postTreatmentLevel, pickerTitle: "Select post pain level", previousValueTaken: (postTreatmentButton.titleLabel?.text)!)
            
        case "Anxiety":
             changePickerDataSource(["0 Not Anxious","1","2","3","4","5","6","7", "8", "9", "10 Worst Anxiety I've Ever Had"], treatmentLevelType: .postTreatmentLevel, pickerTitle: "Select post pain level", previousValueTaken:  (postTreatmentButton.titleLabel?.text)!)
            
        case "Insomnia":
             changePickerDataSource(["0 Best Sleep","1","2","3","4","5","6","7", "8", "9", "10 Worst Sleep I've Ever Had"], treatmentLevelType: .postTreatmentLevel, pickerTitle: "Select post pain level", previousValueTaken: (postTreatmentButton.titleLabel?.text)!)
            
        case "Depression":
             changePickerDataSource(["0 Not Depressed","1","2","3","4","5","6","7", "8", "9", "10 Worst Depression I've Ever Had"], treatmentLevelType: .postTreatmentLevel, pickerTitle: "Select post pain level", previousValueTaken: (postTreatmentButton.titleLabel?.text)!)
            
        default:
            
            let worstLabeltext = "10 Worst " + (typesButton.titleLabel?.text)! + " I've Ever Had"
            
             changePickerDataSource(["0 Best Relief I've Ever Had","1","2","3","4","5","6","7", "8", "9", worstLabeltext], treatmentLevelType: .postTreatmentLevel, pickerTitle: "Select post pain level", previousValueTaken: (postTreatmentButton.titleLabel?.text)!)
        }
        
    }
    
    func changePickerDataSource(dataSourceArray : [String], treatmentLevelType : InputType , pickerTitle : String , previousValueTaken : String){
        openDataPickerWithDataSource(dataSourceArray, input: treatmentLevelType, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: pickerTitle, previousValue: previousValueTaken)
    }
    
    
    // MARK: ANUJ FREQUECY WORK
    func getMostEffectiveFrequency()-> String?{
        
        let data = Logger.fetchCompleteRecords()
        
        
        if data?.count > 0{
            var dictionaryOFchangeAndfrequency = [[Double : Double]]()
            
            for items in data!
            {
                
                let dic : [Double : Double] =  [(items.frequency?.changeIntoDouble())! : (items.postTreatmentPainLevel?.changeIntoDouble())! - (items.preTreatmentPainLevel?.changeIntoDouble())!]
                dictionaryOFchangeAndfrequency.append(dic)
                
            }
            
            print("The Frequency and Change Set :",dictionaryOFchangeAndfrequency)
            
            var hundredfeqArray = [Double]()
            var oneNdHalffeqArray = [Double]()
            var halffeqArray = [Double]()
            
            for key in dictionaryOFchangeAndfrequency{
                for (fre,pain) in key{
                    if fre == 100
                    {
                        hundredfeqArray.append(pain)
                    }
                    else if fre == 1.5
                    {
                        oneNdHalffeqArray.append(pain)
                    }
                    else
                    {
                        halffeqArray.append(pain)
                    }
                    
                }
            }
            
            let sum100 = hundredfeqArray.reduce(0,combine: +)
            let sum1ndhalf = oneNdHalffeqArray.reduce(0,combine: +)
            let sumHalf = halffeqArray.reduce(0,combine: +)
            
            let AverageHundred = (sum100/Double(hundredfeqArray.count)).isNaN ? 1300 : sum100/Double(hundredfeqArray.count)
            let AverageOnenHalf = (sum1ndhalf/Double(oneNdHalffeqArray.count)).isNaN ? 1300 : sum1ndhalf/Double(oneNdHalffeqArray.count)
            let AverageHalf = (sumHalf/Double(halffeqArray.count)).isNaN ? 1300 : sumHalf/Double(halffeqArray.count)
            
            let mostNegative = min(min(AverageHundred, AverageOnenHalf), AverageHalf)
            var Frequency : Double?
            if mostNegative == AverageHundred{
                Frequency = 100.0}
            else if mostNegative == AverageOnenHalf{
                Frequency = 1.5}
            else{
                Frequency = 0.5}
            print ("Most Effective Frequency is:",Frequency)
            
            return String(Frequency!)
            
            
        }
        return nil
    }
    
    
    
    // MARK: ANUJ CURRENT WORK
    
    func getMostEffectiveCurrent()-> String?{
        
        let data = Logger.fetchCompleteRecords()
        
        if data?.count > 0{
            var dictionaryOFchangeAndCurrent = [[Double : Double]]()
            
            for items in data!
            {
                
                let dic : [Double : Double] =  [(items.current?.changeIntoDouble())! : (items.postTreatmentPainLevel?.changeIntoDouble())! - (items.preTreatmentPainLevel?.changeIntoDouble())!]
                dictionaryOFchangeAndCurrent.append(dic)
                
            }
            
            print("The Current and Change Set :",dictionaryOFchangeAndCurrent)
            
            var halfCurrArray = [Double]()
            var oneCurrArray = [Double]()
            var oneHalfCurrArray = [Double]()
            var twoCurrArray = [Double]()
            var twoHalfCurrArray = [Double]()
            var threeCurrArray = [Double]()
            var threeHalfCurrArray = [Double]()
            var fourCurrArray = [Double]()
            var fourHalfCurrArray = [Double]()
            var fiveCurrArray = [Double]()
            var fiveHalfCurrArray = [Double]()
            var sixCurrArray = [Double]()
            
            for key in dictionaryOFchangeAndCurrent{
                for (current,pain) in key{
                    if current == 50
                    {
                        halfCurrArray.append(pain)
                    }
                    else if current == 100
                    {
                        oneCurrArray.append(pain)
                    }
                    else if current == 150
                    {
                        oneHalfCurrArray.append(pain)
                    }
                    else if current == 200
                    {
                        twoCurrArray.append(pain)
                    }
                    else if current == 250
                    {
                        twoHalfCurrArray.append(pain)
                    }
                    else if current == 300
                    {
                        threeCurrArray.append(pain)
                    }
                    else if current == 350
                    {
                        threeHalfCurrArray.append(pain)
                    }
                    else if current == 400
                    {
                        fourCurrArray.append(pain)
                    }
                    else if current == 450
                    {
                        fourHalfCurrArray.append(pain)
                    }
                    else if current == 500
                    {
                        fiveCurrArray.append(pain)
                    }
                    else if current == 550
                    {
                        fiveHalfCurrArray.append(pain)
                    }
                    else
                    {
                        sixCurrArray.append(pain)
                    }
                    
                }
            }
            
            let sumHalf = halfCurrArray.reduce(0,combine: +)
            let sumOne = oneCurrArray.reduce(0,combine: +)
            let sumOneHalf = oneHalfCurrArray.reduce(0,combine: +)
            let sumTwo = twoCurrArray.reduce(0,combine: +)
            let sumTwoHalf = twoHalfCurrArray.reduce(0,combine: +)
            let sumThree = threeCurrArray.reduce(0,combine: +)
            let sumThreeHalf = threeHalfCurrArray.reduce(0,combine: +)
            let sumFour = fourCurrArray.reduce(0,combine: +)
            let sumFourHalf = fourHalfCurrArray.reduce(0,combine: +)
            let sumFive = fiveCurrArray.reduce(0,combine: +)
            let sumFiveHalf = fiveHalfCurrArray.reduce(0,combine: +)
            let sumSix = sixCurrArray.reduce(0,combine: +)
            

            
            let AverageHalf = (sumHalf/Double(halfCurrArray.count)).isNaN ? 1300 : sumHalf/Double(halfCurrArray.count)
            let AverageOne = (sumOne/Double(oneCurrArray.count)).isNaN ? 1300 : sumOne/Double(oneCurrArray.count)
            let AverageOneHalf = (sumOneHalf/Double(oneHalfCurrArray.count)).isNaN ? 1300 : sumOneHalf/Double(oneHalfCurrArray.count)
            let AverageTwo = (sumTwo/Double(twoCurrArray.count)).isNaN ? 1300 : sumTwo/Double(twoCurrArray.count)
            let AverageTwoHalf = (sumTwoHalf/Double(twoHalfCurrArray.count)).isNaN ? 1300 : sumTwoHalf/Double(twoHalfCurrArray.count)
            let AverageThree = (sumThree/Double(threeCurrArray.count)).isNaN ? 1300 : sumThree/Double(threeCurrArray.count)
            let AverageThreeHalf = (sumThreeHalf/Double(threeHalfCurrArray.count)).isNaN ? 1300 : sumThreeHalf/Double(threeHalfCurrArray.count)
            let AverageFour = (sumFour/Double(fourCurrArray.count)).isNaN ? 1300 : sumFour/Double(fourCurrArray.count)
            let AverageFourHalf = (sumFourHalf/Double(fourHalfCurrArray.count)).isNaN ? 1300 : sumFourHalf/Double(fourHalfCurrArray.count)
            let AverageFive = (sumFive/Double(fiveCurrArray.count)).isNaN ? 1300 : sumFive/Double(fiveCurrArray.count)
            let AverageFiveHalf = (sumFiveHalf/Double(fiveHalfCurrArray.count)).isNaN ? 1300 : sumFiveHalf/Double(fiveHalfCurrArray.count)
            let AverageSix = (sumSix/Double(sixCurrArray.count)).isNaN ? 1300 : sumSix/Double(sixCurrArray.count)

            
            let AverageArray = [AverageHalf,AverageOne,AverageOneHalf,AverageTwo,AverageTwoHalf,AverageThree,AverageThreeHalf,AverageFour,AverageFourHalf,AverageFive,AverageFiveHalf,AverageSix]
            
            var Current : Double?
            
            let mini = AverageArray.sort({$0<$1})
            print(mini)
            
            let indexOf = AverageArray.indexOf(mini[0])
            print(indexOf!)
            
            if indexOf == 0
            {
                print("The most Effective current is: 50 µA")
                Current = 50
            }
            if indexOf == 1
            {
                print("The most Effective current is: 100 µA")
                Current = 100
            }
            if indexOf == 2
            {
                print("The most Effective current is: 150 µA")
                Current = 150
            }
            if indexOf == 3
            {
                print("The most Effective current is: 200 µA")
                Current = 200
            }
            if indexOf == 4
            {
                print("The most Effective current is: 250 µA")
                Current = 250
            }
            if indexOf == 5
            {
                print("The most Effective current is: 300 µA")
                Current = 300
            }
            if indexOf == 6
            {
                print("The most Effective current is: 350 µA")
                Current = 350
            }
            if indexOf == 7
            {
                print("The most Effective current is: 400 µA")
                Current = 400
            }
            if indexOf == 8
            {
                print("The most Effective current is: 450 µA")
                Current = 450
            }
            if indexOf == 9
            {
                print("The most Effective current is: 500 µA")
                Current = 500
            }
            if indexOf == 10
            {
                print("The most Effective current is: 550 µA")
                Current = 550
            }
            if indexOf == 11
            {
                print("The most Effective current is: 600 µA")
                Current = 600
            }
            return String(Current!)
        }
        return nil
    }
    
    
    //Anuj Change 29/05/2017
    /**
     Function is called when Frequency button is pressed.
     */
    @IBAction func frequencyPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        openDataPickerWithDataSource(["0.5 Hz","1.5 Hz","100 Hz"], input: InputType.frequencyLevel, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: "Select frequency", previousValue: (frequencyButton.titleLabel?.text)!)
    }
    
    @IBAction func addSelectPatientPressed(sender: UIButton) {
        
        navigateToPatientAndSelection()
    }
    /**
     Function is called when Current button is pressed.
     */
    @IBAction func currentPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        openDataPickerWithDataSource(["50 µA", "100 µA", "150 µA", "200 µA", "250 µA","300 µA","350 µA","400 µA","450 µA","500 µA","550 µA","600 µA"], input: InputType.currentLevel, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: "Select current", previousValue: (currentButton.titleLabel?.text)!)
    }
    
    //End of Anuj Change 29/05/2017
    
    //Mohit Change
    /**
     Function is called when Treatment area button is pressed.
     */
    @IBAction func treatmentAreaButtonPressed(sender: AnyObject) {
        showBodyParts()
    }
    
    //Mohit change
    // Function to load the xib of BodyParts based on the specific device height, in which the page is being opened.
    func showBodyParts(){
        print(self.view.frame.height)
        if (self.view.frame.height == 568){
            let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts", bundle: nil)
            humanBodyViewController.isComingFromLoggerScreen = "true"
            humanBodyViewController.delegateHumanBodyViewControllerProtocol = self
            self.navigationController?.pushViewController(humanBodyViewController, animated: true)
            
            
        } else if  (self.view.frame.height == 667){
            let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts6", bundle: nil)
            humanBodyViewController.isComingFromLoggerScreen = "true"
            humanBodyViewController.delegateHumanBodyViewControllerProtocol = self
            self.navigationController?.pushViewController(humanBodyViewController, animated: true)
            
        }else if (self.view.frame.height == 736){
            let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts6P", bundle: nil)
            humanBodyViewController.isComingFromLoggerScreen = "true"
            humanBodyViewController.delegateHumanBodyViewControllerProtocol = self
            self.navigationController?.pushViewController(humanBodyViewController, animated: true)
            
        }
    }
    
    /**
     Function is called when Date & Time button is pressed.
     */
    @IBAction func dateTimePressed(sender: AnyObject) {
        removePickerSubView()
        self.navigationController?.navigationBarHidden = true
        let datePicker: EPDatePickerView = EPDatePickerView.initWithNib() as! EPDatePickerView
        datePicker.delegate = self
        datePicker.pickerTitle.text = "Select date & time"
        datePicker.inputSelection = InputType.dateTime
        datePicker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.view.addSubview(datePicker)
    }
    
    
    /**
     Function is called when Types button is pressed.
     */
    @IBAction func typesPressed(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = true
        
        // PREVIOUS code
        
        //openDataPickerWithDataSource(["Pain","Anxiety","Insomnia","Depression"], input: InputType.type, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: "Select pain type", previousValue: (typesButton.titleLabel?.text)!)
        
        // Mohit change
        
    
        
        openDataPickerWithDataSource(typesOfDiseasesDataSource, input: InputType.type, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), pickerTitleText: "Select indication type", previousValue: (typesButton.titleLabel?.text)!)
        
        
    }
    
    /**
     Function is called when Submit Button is pressed.
     */
    @IBAction func submitButton(sender: AnyObject) {
        
        
        
        disableButtons(false)
        if (preTreatmentButton.titleLabel?.text == "Select")  || (dateTimeButton.titleLabel?.text == "Select") || (typesButton.titleLabel?.text == "Select") || (frequencyButton.titleLabel?.text == "Select") || (currentButton.titleLabel?.text == "Select") {
            self.showAlert("Please enter all values")
            return
        }
        
        if (typesButton.titleLabel?.text == "Pain") && (treatmentAreaButton.titleLabel?.text == "Select"){
            self.showAlert("Please select treatment area")
            return
        }

        // Mohit change
//        if let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String{
//            if userDeviceModel == "Alpha-Stim AID"{
//                if typesButton.titleLabel?.text == "Pain"{
//                    let alertController = UIAlertController(title: "", message: "Please select applicable category.", preferredStyle: .Alert)
//                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action) in
//                    })
//                    alertController.addAction(okAction)
//                    self.presentViewController(alertController, animated: true, completion: nil)
//                    return
//                }
//                
//            }
//            
//        }
        
        logDate = LoggerViewController.getDateTimeInNSDate((dateTimeButton.titleLabel?.text)!)
        
        // Mohit change : for showing the units against values for frequency, current and treatment duration textfield.
        let treatmentDurationFirstPartString = treatmentButton.titleLabel?.text?.getStringsFirstComponent()
        treatmentButton.titleLabel?.text = treatmentDurationFirstPartString
        
        let frequencyFirstValue = frequencyButton.titleLabel?.text?.getStringsFirstComponent()
        frequencyButton.titleLabel?.text = frequencyFirstValue
        
        let currentFirstValue = currentButton.titleLabel?.text?.getStringsFirstComponent()
        currentButton.titleLabel?.text = currentFirstValue
        
        if isHandlingIncompleteEntry == false{
            if checkForSametypeIncompleteEntries((typesButton.titleLabel?.text!)!){
                alertForIncompleteEntries((typesButton.titleLabel?.text!)!)
            }else{
                
                if dateExistsInDB(logDate){
                    checkForRecord(Int(preTreatmentButton.titleLabel!.text!)!,postTreatmentPainLevel: Int(postTreatmentButton.titleLabel!.text!) ,treatmentDuration: Int(treatmentButton.titleLabel!.text!), Date: logDate, type: typesButton.titleLabel!.text!, frequency: Double((frequencyButton.titleLabel?.text)!)!, current: Double((currentButton.titleLabel?.text)!)!, treatmentArea: (treatmentAreaButton.titleLabel?.text)!)
                    
                }else{
                    Logger.addHistory(Int(preTreatmentButton.titleLabel!.text!)!, postTreatmentPainLevel: Int(postTreatmentButton.titleLabel!.text!),  treatmentDuration: Int(treatmentButton.titleLabel!.text!), Date: logDate, type: typesButton.titleLabel!.text!, frequency: Double((frequencyButton.titleLabel?.text)!)!, current: Double((currentButton.titleLabel?.text)!)!, treatmentArea: (treatmentAreaButton.titleLabel?.text)!)
                    resetValues()
                    self.resetTreatmentAreaButton("Select")
                    historyView?.refreshView()
                    //Mohit Change
                    //SyncManager.syncData(true)
                }
            }
            
            
            
        } else{
            
            if recordObjectID != nil{
                findExistingObjectID(recordObjectID!, preTreatmentPainLevel: Int(preTreatmentButton.titleLabel!.text!)!,postTreatmentPainLevel: Int(postTreatmentButton.titleLabel!.text!) ,treatmentDuration: Int(treatmentButton.titleLabel!.text!), Date: logDate, type: typesButton.titleLabel!.text!)
                
            }
            //Mohit Change
             //SyncManager.syncData(true)
            
        }
        
       // manageEffectiveValues()
        
           SyncManager.syncData(true)
        
         
    }
    
    
    
    func findExistingObjectID(id : NSManagedObjectID ,preTreatmentPainLevel: Int,postTreatmentPainLevel : Int? , treatmentDuration: Int?, Date: NSDate, type: String){
        let logs = Logger.fetchAllHistory()
        if logs != nil{
            if recordObjectID != nil{
                for log in logs!{
                    if recordObjectID == log.objectID{
                        log.preTreatmentPainLevel = preTreatmentPainLevel
                        log.postTreatmentPainLevel = postTreatmentPainLevel
                        log.treatmentDuration = treatmentDuration
                        log.dateTime = Date
                        log.categories = type
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext
                        
                        do {
                            try managedContext.save()
                        }
                        catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                        self.historyView?.refreshView()
                        resetValues()
                        
                    }
                }
            }
        }
        
    }
    
    func dateExistsInDB(dateInserted : NSDate)-> Bool{
        let logs = Logger.fetchAllHistory()
        if logs != nil {
            for records in logs! {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let newDate = dateFormatter.stringFromDate(dateInserted)
                let savedDate = dateFormatter.stringFromDate(records.dateTime!)
                if newDate == savedDate {
                    return true
                }
            }
        }
        return false
    }
    
    func updateObjectInDB( record : Logger,preTreatmentPainLevel: Int,postTreatmentPainLevel : Int? , treatmentDuration: Int?, Date: NSDate, type: String, frequency : Double , current : Double, treatmentArea : String){
        record.preTreatmentPainLevel = preTreatmentPainLevel
        record.postTreatmentPainLevel = postTreatmentPainLevel
        record.treatmentDuration = treatmentDuration
        record.dateTime = Date
        record.categories = type
        record.frequency = frequency
        record.current = current
        if treatmentArea == "Select"{
            record.treatmentArea = ""
        }else{
            record.treatmentArea = treatmentArea
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        do {
            try managedContext.save()
        }
        catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        self.historyView?.refreshView()
        resetValues()
        
    }
    
    func checkForRecord(preTreatmentPainLevel: Int,postTreatmentPainLevel : Int? , treatmentDuration: Int?, Date: NSDate, type: String, frequency : Double, current : Double, treatmentArea : String){
        
        
        let records = Logger.checkIfCategoryExixtsInDB(Date, categoryInserted: type)
        // Allow user to enter 2 conditions of same type for a date. Previously the records.count > 0
        if records?.count > 1{
            print("working")
            for record in records!{
                if isHandlingIncompleteEntry == true{
                    updateObjectInDB(record, preTreatmentPainLevel: preTreatmentPainLevel, postTreatmentPainLevel: postTreatmentPainLevel, treatmentDuration: treatmentDuration, Date: Date, type: type, frequency: frequency, current: current,treatmentArea: treatmentArea)
                    isHandlingIncompleteEntry = false
                    //Mohit Change
                    //SyncManager.syncData(true)
                }else{
                    let alertController = UIAlertController(title: "", message: "Do you want to override \(record.categories!) log added on \(record.dateWithoutTime!)", preferredStyle: .Alert)
                    
                    // Create the actions
                    let overrideAction = UIAlertAction(title: "Override Log", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.updateObjectInDB(record, preTreatmentPainLevel: preTreatmentPainLevel, postTreatmentPainLevel: postTreatmentPainLevel, treatmentDuration: treatmentDuration, Date: Date, type: type, frequency: frequency, current: current,treatmentArea: treatmentArea)
                    }
                    let viewLogAction = UIAlertAction(title: "View Log", style: UIAlertActionStyle.Cancel) {
                        UIAlertAction in
                        
                        self.historyView!.showSelectedcell(record.objectID)
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(viewLogAction)
                    alertController.addAction(overrideAction)
                    
                    // Present the controller
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }
        }else{
            if checkForSametypeIncompleteEntries((typesButton.titleLabel?.text!)!){
                alertForIncompleteEntries((typesButton.titleLabel?.text!)!)
            }else{
                Logger.addHistory(preTreatmentPainLevel, postTreatmentPainLevel: postTreatmentPainLevel, treatmentDuration: treatmentDuration, Date: Date, type: type , frequency: frequency , current: current, treatmentArea:  treatmentArea)
                resetValues()
                historyView?.refreshView()
                //Mohit Change
                //SyncManager.syncData(true)
                
            }
            
        }
    }
    
    /**
     Function is used to show alert if there is an incomplete entry.
     - parameter painType : Type of pain i.e. Anxiety, Insomia, Depression and Pain.
     */
    func alertForIncompleteEntries(painType : String){
        let alert = UIAlertController(title: "", message: "There is an incomplete entry for \(painType), please complete it/delete it first", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.isHandlingIncompleteEntry = true
            self.fillTheFields(painType)
        })
        alert.addAction(okAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //check for any same type i.e. pain anxiety depression insomia incomplete entries.
    /**
     Function is used to check for any same type i.e. pain anxiety depression insomia incomplete entries.
     - parameter type: Tells the type i.e. Insomnia, Depression, Pain, Anxiety.
     - returns: Bool, return True if found any incomplete values othervise False
     */
    func checkForSametypeIncompleteEntries(type : String) -> Bool{
        
        let dataLogs = Logger.fetchAllHistory()
        if dataLogs != nil{
            for log in dataLogs!{
                if log.categories == type{
                    if log.postTreatmentPainLevel == nil || log.treatmentDuration == nil{
                        recordObjectID = log.objectID
                        return true
                    }
                }
            }
            
        }
        
        return false
    }
    
    
    /**
     function is used to fill the post treatment, pre treatment, treatment duration and date when an incomplete entry in submitted type is found.
     - parameter type: Tells the type i.e. Insomnia, Depression, Pain, Anxiety.
     */
    func fillTheFields(type : String){
        
        let datalogs = Logger.fetchAllHistory()
        if datalogs != nil{
            for log in datalogs!{
                if log.categories == type{
                    if log.postTreatmentPainLevel == nil || log.treatmentDuration == nil{
                        self.historyView!.showSelectedcell(log.objectID)
                        
                        fill(log)
                        
                    }
                }
            }
        }
        
    }
    
    
    
    
    /** Function to check if the entry for same date is present in logs.If the entry is already present, then user is asked if he/ she wants
     to overwrite the previous value. If the user taps on "Yes", the values is overwritten, else the new valus is discarded. The user can record only 1 log value for a specific date/ time
     */
    func checkForNewLog(preTreatmentPainLevel: Int,postTreatmentPainLevel : Int? , treatmentDuration: Int?, Date: NSDate, type: String)->Bool{
        var status = true
        let logs = Logger.fetchAllHistory()
        if logs != nil {
            for l in logs! {
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let newDate = dateFormatter.stringFromDate(Date)
                let savedDate = dateFormatter.stringFromDate(l.dateTime!)
                if newDate == savedDate {
                    status = false
                    
                    if type == l.categories{
                        let alertController = UIAlertController(title: "", message: "Do you want to overide \(l.categories!) log added on \(savedDate)", preferredStyle: .Alert)
                        // Create the actions
                        let overrideAction = UIAlertAction(title: "Override Log", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            NSLog("OK Pressed")
                            //Update object in data base
                            l.dateTime = Date
                            l.treatmentDuration = treatmentDuration
                            l.preTreatmentPainLevel = preTreatmentPainLevel
                            l.categories = type
                            l.postTreatmentPainLevel = postTreatmentPainLevel
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let managedContext = appDelegate.managedObjectContext
                            
                            do {
                                try managedContext.save()
                            }
                            catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                            
                            self.historyView?.refreshView()
                            self.resetValues()
                        }
                        let viewLogAction = UIAlertAction(title: "View Log", style: UIAlertActionStyle.Cancel) {
                            UIAlertAction in
                            
                            self.historyView!.showSelectedcell(l.objectID)
                            
                        }
                        
                        // Add the actions
                        
                        alertController.addAction(viewLogAction)
                        alertController.addAction(overrideAction)
                        // Present the controller
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return false
                        
                    } else{
                        //Logger.addHistory(preTreatmentPainLevel, postTreatmentPainLevel: postTreatmentPainLevel,  treatmentDuration: treatmentDuration, Date:Date, type: type)
                        resetValues()
                        historyView?.refreshView()
                        return false
                    }
                    
                                       
                }
                
            }
        }
        return status
    }
    
       
    /**
     Function to remove added subview of picker type.
     This will check for any EPPicker or EPDatePicker class
     and if such view is found added to controller's view then that
     will be removed from parent or super view.
     */
    func removePickerSubView(){
        
        for subView in self.view.subviews {
            
            if subView.isKindOfClass(EPPickerView) || subView.isKindOfClass(EPDatePickerView){
                
                subView.removeFromSuperview()
            }
            
        }
        
    }
    
    /**
     Function to open picker and add the picker on view. It takes the data source parameter and type identifier
     to set the EPPicker details with that UIPicker will be added.
     - parameter dataSource: [String]: Array of string
     - parameter input: Enum InputType to identify which button is pressed
     - parameter frame: The frame at which picker needs to be placed
     */
    
    func openDataPickerWithDataSource(dataSource: [String], input: InputType, frame: CGRect, pickerTitleText: String, previousValue: String){
        removePickerSubView()
        
        
        let picker: EPPickerView = EPPickerView.initWithNib() as! EPPickerView
        picker.delegate = self
        picker.pickerDataSoruce = dataSource
        if let previousIndex = dataSource.indexOf(previousValue) {
            picker.selectedValue = previousIndex
            picker.picker.selectRow(previousIndex, inComponent: 0, animated: false)
        }
        picker.inputSelection = input
        picker.frame = frame
        picker.pickerTitle.text = pickerTitleText
        self.view.addSubview(picker)
    }
    
    /**
     EPPicker delegate method which will set the selected item value
     from sent datasource and remove the picker from superview.
     A switch based input type is implemented to identify the button
     and set the new selected value as button title.
     */
    func didFinishSelectingRow(row: Int, dataSource: [String], input: InputType) {
        switch input {
            
        case .treatmentDuration:
            
            let data = dataSource[row]
            
           // let newString = data.stringByReplacingOccurrencesOfString(" mins", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

            
            treatmentButton.setTitle(data, forState: .Normal)
            hidePickerFromSuperView()
            break
        case .preTreatmentLevel:
            // to check whether the string contains more than one charater or not. If yes, then further checked if the string contains "None" or "Worst". In case of "None" only the starting character is taken from the string and in case of "Worst" starting two characters are taken from the string.
            let data = dataSource[row]
            var index : String.Index?
            var dataTaken : String?
            if data.characters.count == 1{
                preTreatmentButton.setTitle(dataSource[row], forState: .Normal)
            }else{
                print(data)
                if data.containsString("No Pain") || data.containsString("Not") || data.containsString("Best") || data.containsString("None") || data.containsString("Best Relief I've Ever Had") {
                    index = data.startIndex.advancedBy(1)
                    dataTaken = data.substringToIndex(index!)
                    print(dataTaken)
                }else{
                    index = data.startIndex.advancedBy(2)
                    dataTaken = data.substringToIndex(index!)
                }
                preTreatmentButton.setTitle(dataTaken!, forState: .Normal)
            }
             hidePickerFromSuperView()
            break
        case .dateTime:
             hidePickerFromSuperView()
            break
        case .type:
            
            // Previous code
//            levelLabel.text = "\(dataSource[row]) Level"
//            typesButton.setTitle(dataSource[row], forState: .Normal)
            
            
            // Mohit change
            
        
            
            if let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String{
                if userDeviceModel == "Alpha-Stim AID"{
                    let selectedRowText = dataSource[row]
                    if selectedRowText == "Pain"{
                        // Do nothing
                    }else{
                        let selectedRowText = dataSource[row]
                        typesRowSelected = row
                        //"Anxiety","Insomnia","Depression"
                        if selectedRowText == "Pain"{
                            treatmentAreaButton.enabled = true
                        }else if selectedRowText == "Anxiety" || selectedRowText == "Insomnia" || selectedRowText == "Depression"{
                            treatmentAreaButton.enabled = false
                            resetTreatmentAreaButton("Brain")
                        }else{
                            treatmentAreaButton.enabled = false
                            resetTreatmentAreaButton("Select")
                        }
                        
                        if selectedRowText == "Enter Custom Indication"{
                            self.showAlertWithTextField()
                        }else{
                            levelLabel.text = "\(dataSource[row]) Level"
                            typesButton.setTitle(dataSource[row], forState: .Normal)
                        }
                        hidePickerFromSuperView()
                    }
                }else{
                    let selectedRowText = dataSource[row]
                    typesRowSelected = row
                    //"Anxiety","Insomnia","Depression"
                    if selectedRowText == "Pain"{
                        treatmentAreaButton.enabled = true
                         resetTreatmentAreaButton("Select")
                    }else if selectedRowText == "Anxiety" || selectedRowText == "Insomnia" || selectedRowText == "Depression"{
                        treatmentAreaButton.enabled = false
                        resetTreatmentAreaButton("Brain")
                    }else{
                        treatmentAreaButton.enabled = false
                        resetTreatmentAreaButton("Select")
                    }
                    
                    if selectedRowText == "Enter Custom Indication"{
                        self.showAlertWithTextField()
                    }else{
                        levelLabel.text = "\(dataSource[row]) Level"
                        typesButton.setTitle(dataSource[row], forState: .Normal)
                    }
                    hidePickerFromSuperView()

                }
            }
            
            break
        case .postTreatmentLevel:
            
            // to check whether the string contains more than one charater or not. If yes, then further checked if the string contains "None" or "Worst". In case of "None" only the starting character is taken from the string and in case of "Worst" starting two characters are taken from the string.
            let data = dataSource[row]
            var index : String.Index?
            var dataTaken : String?
            if data.characters.count == 1{
                postTreatmentButton.setTitle(dataSource[row], forState: .Normal)
            }else{
                if data.containsString("No Pain") || data.containsString("Not") || data.containsString("Best") || data.containsString("None") || data.containsString("Best Relief I've Ever Had"){
                    index = data.startIndex.advancedBy(1)
                    dataTaken = data.substringToIndex(index!)
                }else{
                    index = data.startIndex.advancedBy(2)
                    dataTaken = data.substringToIndex(index!)
                }
                postTreatmentButton.setTitle(dataTaken!, forState: .Normal)
                
            }
            //postTreatmentButton.setTitle(dataSource[row], forState: .Normal)
             hidePickerFromSuperView()
            break
        // Anuj Change 29/05/2017
        case .frequencyLevel:
            frequencyButton.setTitle(dataSource[row], forState: .Normal)
             hidePickerFromSuperView()
            break
        case .currentLevel:
            currentButton.setTitle(dataSource[row], forState: .Normal)
             hidePickerFromSuperView()
            break
        
            // End of Anuj Change 29/05/2017
        }
        
        
//        self.navigationController?.navigationBarHidden = false
//        removePickerSubView()
    }
    
    //Mohit change
    func hidePickerFromSuperView(){
        self.navigationController?.navigationBarHidden = false
        removePickerSubView()
    }
    
    func resetTreatmentAreaButton(areaTaken : String){
        treatmentAreaButton.setTitle(areaTaken, forState: .Normal)
    }
    
    
    func showAlertWithTextField(){
        
        var dataTaken : String = ""
    
        let alertController = UIAlertController(title: "", message: "Please enter the custom indication", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {

                print(field.text)

                dataTaken = field.text!
                
                // Check if Text field text is blank or not
                
                if dataTaken.characters.count > 0{
                    
                // Remove white spaces from the textField text
                    dataTaken = dataTaken.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    if dataTaken.characters.count > 0{

                        // Make the first letter of the string capital
                        field.text!.replaceRange(field.text!.startIndex...field.text!.startIndex, with: String(field.text![field.text!.startIndex]).capitalizedString)

                        // Change the button and label name
                        self.levelLabel.text = "\(field.text!) Level"
                        self.typesButton.setTitle(field.text, forState: .Normal)
                        
                        // Checking if user has selected type row i.e the variable typesRowSelected is nil or not
                        if self.typesRowSelected != nil{
                            self.typesOfDiseasesDataSource[self.typesRowSelected!] = field.text!
                            NSUserDefaults.standardUserDefaults().setObject(self.typesOfDiseasesDataSource, forKey: "categoryDataSource")
                        }
                    }
                }

            } else {
                // User did not fill field and change the button and label name to default value i.e Pain
                //self.levelLabel.text = "Pain Level"
                //self.typesButton.setTitle("Pain", forState: .Normal)
                
                //Mohit CR3 Change
                // The default will change according to the model id that user is using i.e Alpha-Stim AID and Alpha-Stim M.
                let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String
                if (userDeviceModel != nil) && (userDeviceModel == "Alpha-Stim AID"){
                    self.levelLabel.text = "Anxiety Level"
                    self.typesButton.setTitle( "Anxiety", forState: .Normal)
                }else{
                    self.levelLabel.text = "Pain Level"
                    self.typesButton.setTitle( "Pain", forState: .Normal)
                }

               
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Custom indication"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    /**
     EPDatePickerDelegate method to set the selected date on
     dateTime button.
     */
    func didFinishSelectingDate(selectedDate: String, input: InputType){
        self.navigationController?.navigationBarHidden = false
        dateTimeButton.setTitle(" " + selectedDate, forState: .Normal)
        removePickerSubView()
    }
    /** Function to add History Table view onto the lower portion of the screen.
     This view acts as the recorder/ logger and displays recorded information.
     The user can swipe the table view cell to left and delete record as well.
     */
    func addHistoryTableView(frame: CGRect) {
        historyView = EPHistoryTableView.initWithNib() as? EPHistoryTableView
        historyView?.frame = frame
        historyView?.delegate = self
        historyView?.dataSource = Logger.fetchAllHistory()!
        historyView?.historyTable.registerNib(UINib(nibName: "EPHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "EPHistoryTableViewCell")
        tableContainer.addSubview(historyView!)
    }
    
    func cancelButtonClicked() {
        self.navigationController?.navigationBarHidden = false
        self.removePickerSubView()
    }
    // For resetting the entered values.
    @IBAction func resetButtonClicked(sender: AnyObject) {
        resetValues()
        
    }
    
    
    /**
     Function is used to reset all values
     */
    func resetValues(){
        
        //Mohit CR3 Change
        // The default will change according to the model id that user is using i.e Alpha-Stim AID and Alpha-Stim M.
        let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String
        print(userDeviceModel)
        if (userDeviceModel != nil) && (userDeviceModel == "Alpha-Stim AID"){
            levelLabel.text = "Anxiety Level"
            typesButton.setTitle( "Anxiety", forState: .Normal)
            // Mohit Change - set title not workig as expected
            typesButton.titleLabel?.text = "Anxiety"
            treatmentAreaButton.setTitle( "Brain", forState: .Normal)
        }else{
            levelLabel.text = "Pain Level"
            typesButton.setTitle( "Pain", forState: .Normal)
            // Mohit Change - set title not workig as expected
            typesButton.titleLabel?.text = "Pain"
            treatmentAreaButton.setTitle( "Select", forState: .Normal)
        }
        
        preTreatmentButton.setTitle( "Select", forState: .Normal)
        postTreatmentButton.setTitle("Select", forState: .Normal)
        treatmentButton.setTitle( "Select", forState: .Normal)
        //dateTimeButton.setTitle( "Select", forState: .Normal)
        frequencyButton.setTitle( "Select", forState: .Normal)
        currentButton.setTitle( "Select", forState: .Normal)
        treatmentAreaButton.enabled = true
        setDefaultTime()
        isHandlingIncompleteEntry = false
        disableButtons(false)
        self.historyView?.refreshView()
        var customIndicationFields = findCustomIndicationFields()
        for items in customIndicationFields{
            if isCategoryExixtesInDB(items){
            // Entry exixts in DB so we have to do nothing with it
            }else{
                changeToCustomCategoryInCategoryDataSource(items)
            }
        }
    }
    
    func changeToCustomCategoryInCategoryDataSource(categoryName : String){
        for i in 0..<typesOfDiseasesDataSource.count{
            if typesOfDiseasesDataSource[i] == categoryName{
                typesOfDiseasesDataSource[i] = "Enter Custom Indication"
            }
        }
    }
    
    func isCategoryExixtesInDB(category : String)-> Bool{
        let allRecords = Logger.fetchAllHistory()
        var status : Bool = false
        for record in allRecords!{
            if record.categories == category{
                status = true
            }
        }
        return status
    }
    
    func findCustomIndicationFields()-> [String]{
        var customCategoryNameArray : [String] = []
        for category in typesOfDiseasesDataSource{
            if category == "Pain" || category == "Anxiety" || category == "Insomnia" || category == "Depression" {
                // do nothing
            }else{
                customCategoryNameArray.append(category)
            }
        }
        return customCategoryNameArray
    }
    
    /**
     Function to convert String object to NSDate type object. The date format can be updated here for different types of date formats.
     - parameter dateReceived: of type String and converted into NSDate value which is returned by the method
     */
   class func getDateTimeInNSDate(dateReceived: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let dateString = dateFormatter.dateFromString(dateReceived)
        return dateString!
    }
    
    func getDateTime(dateReceived: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        let dateString = dateFormatter.dateFromString(dateReceived)
        return dateString!
    }
    
    /**
     Function used to convert the date taken from the DB to the required format.
     - parameter dateTakenFromDB, of type NSDate and is converted into required format.
     - returns: String, date of required format is converted into string and returned.
     */
    func convertDateTakenFromDB(dateTakenFromDB : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let dateString = dateFormatter.stringFromDate(dateTakenFromDB)
        return dateString
        
    }
    
    /**
     Function fetch current date and time  that is required format and display on dateTimebutton title.
     */
    func setDefaultTime() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let currentDateTime = NSDate()
        let dateTimeString = dateFormatter.stringFromDate(currentDateTime)
        dateTimeButton.setTitle( dateTimeString, forState: .Normal)
    }
    
    
    /**
     function is used to find the recent incomplete entry in the DB.
     */
    func showrecentIncompleteEntry(){
        let logs = Logger.findRecentIncompleteRecord()
        if logs != nil{
            for log in logs!{
                if log.postTreatmentPainLevel == nil || log.treatmentDuration == nil {
                    let alert = UIAlertController(title: "", message:  "There is an incomplete entry for \(log.categories!), please complete it/delete it first", preferredStyle: .Alert)
                    
                    let yesAction = UIAlertAction(title: "YES", style: .Default, handler: { action in
                        self.fill(log)
                        self.isHandlingIncompleteEntry = true
                        self.recordObjectID = log.objectID
                        self.historyView!.showSelectedcell(log.objectID)
                        
                    })
                    let noAction = UIAlertAction(title: "NO", style: .Default, handler: {action in
                        self.historyView?.refreshView()
                    })
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: PROTOCOL DELEGATE METHOD
    /**
     function used to fill the labels when table view cell is selected
     */
    func getData(log: Logger) {
        
        if log.postTreatmentPainLevel == nil || log.treatmentDuration == nil{
            isHandlingIncompleteEntry = true
            recordObjectID = log.objectID
            fill(log)
        }
    }
    
    
    func disableButtons(status : Bool){
        if status == true{
            preTreatmentButton.enabled = false
            dateTimeButton.enabled = false
            typesButton.enabled = false
            currentButton.enabled = false
            frequencyButton.enabled = false
            treatmentAreaButton.enabled = false
            
        }else{
            preTreatmentButton.enabled = true
            dateTimeButton.enabled = true
            typesButton.enabled = true
            currentButton.enabled = true
            frequencyButton.enabled = true
            let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String
            if userDeviceModel == "Alpha-Stim AID"{
                if typesButton.titleLabel?.text == "Pain"{
                    treatmentAreaButton.enabled = true
                }else{
                    treatmentAreaButton.enabled = false
                }
            }
//            treatmentAreaButton.enabled = true
        }
    }
    
    func fill(log : Logger){
        
        disableButtons(true)
        if log.postTreatmentPainLevel == nil{
            self.postTreatmentButton.setTitle("Select", forState: .Normal)
        }else{
            self.postTreatmentButton.setTitle(String(log.postTreatmentPainLevel!), forState: .Normal)
        }
        
        
        self.preTreatmentButton.setTitle(String(log.preTreatmentPainLevel!), forState: .Normal)
        self.typesButton.setTitle(log.categories, forState: .Normal)
        
        if log.treatmentDuration == nil{
            self.treatmentButton.setTitle("Select", forState: .Normal)
        }else{
            self.treatmentButton.setTitle(String(log.treatmentDuration!), forState: .Normal)
        }
        
        let date = self.convertDateTakenFromDB(log.dateTime!)
        self.dateTimeButton.setTitle(date, forState: .Normal)
        
        self.frequencyButton.setTitle((log.frequency?.stringValue)! + " Hz", forState: .Normal)
        self.currentButton.setTitle((log.current?.stringValue)! + " µA", forState: .Normal)
        
        if log.treatmentArea == ""{
        self.treatmentAreaButton.setTitle("Select", forState: .Normal)
        }else{
        self.treatmentAreaButton.setTitle(log.treatmentArea, forState: .Normal)
        }
        
        
    }
    
    @IBAction func logoutPressed(sender: UIButton) {
        
        /**
        let alert = UIAlertController(title: "", message: "Data will get lost without syncing. Do you want to logout?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            Logger.deleteAlldataFromDB()
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "practitionerCode")
            let storyLogin = UIStoryboard(name: "Login", bundle: nil)
            let loginVcNavigationController : EPNavigationController = storyLogin.instantiateViewControllerWithIdentifier("EPNavigationController") as! EPNavigationController
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookie")
            self.view.window?.rootViewController = loginVcNavigationController
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
//        let storyLogin = UIStoryboard(name: "Login", bundle: nil)
//        let loginVcNavigationController : UINavigationController = storyLogin.instantiateViewControllerWithIdentifier("navigationControllerMain") as! UINavigationController
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookie")
//        self.view.window?.rootViewController = loginVcNavigationController
 
 **/
        
        self.logoutPressed()
        
    }
    
    
    @IBAction func exportPressed(sender: UIButton) {
        if let csvData = genrateCSVFileOfLoggerData(){
            openMailComposer(csvData, fileName: "logs.csv")
        }
    }
    
    
    func genrateCSVFileOfLoggerData()->String?{
        guard let loggerData = Logger.fetchCompleteRecords() else{
            return nil
        }
        if loggerData.count >  0{
            let firstObject = loggerData[0]
            var attributes = Array(firstObject.entity.attributesByName.keys)
            
            for string in attributes{
                var newString = string
                newString.replaceRange(string.startIndex...string.startIndex, with: String(string[string.startIndex]).capitalizedString)
                let index = attributes.indexOf(string)
                attributes[index!] = newString
            }
            
            let i = attributes.indexOf("Id")
            attributes.removeAtIndex(i!)
            
            let j = attributes.indexOf("DateTime")
            attributes.removeAtIndex(j!)
            
            let k = attributes.indexOf("DateWithoutTime")
            attributes.removeAtIndex(k!)
            
            let m = attributes.indexOf("Date")
            
            
            let csvHeaderString =  (attributes.reduce("", combine: { ($0 as String) + "," + $1}) as NSString).substringFromIndex(1) + "\n"
            
            let csvArray = loggerData.map({ object in (attributes.map({(object.valueForKey($0) ?? "NIL").description}).reduce("",combine:{$0 + "," + $1}) as NSString).substringFromIndex(1) + "\n"})
            let csvString = csvArray.reduce("",combine: +)
            print(csvHeaderString + csvString)
            return csvHeaderString + csvString
        }else{
            //Show alert here
            let records = Logger.fetchAllHistory()
            if records!.count > 0{
                exportAlert("Please complete record first")
                return nil
            }else{
                exportAlert( "No record present to export")
                return nil
            }
            
            
        }
        
    }
    
    
    func exportAlert(message : String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openMailComposer(csvFile: String, fileName: String){
        guard let data = csvFile.dataUsingEncoding(NSUTF8StringEncoding)
            else{ return}
        var mailComposer: MFMailComposeViewController?
        if MFMailComposeViewController.canSendMail(){
            mailComposer = MFMailComposeViewController()
            
            let emailTitle = "Logs report in CSV Format attached"
            let messageBody = "Report are attached in CSV format"
            mailComposer?.addAttachmentData(data, mimeType: "text/csv", fileName:fileName)
            mailComposer?.setSubject(emailTitle)
            mailComposer?.setMessageBody(messageBody, isHTML: false)
            mailComposer?.mailComposeDelegate = self
            self.presentViewController(mailComposer!, animated: true, completion: nil)
            
        }else{
            //can sent mail alert here
            self.showAlert("Please configure your email account.")
        }
        
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result {
        case MFMailComposeResult.Cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.Sent:
            print("Mail cancelled")
        case MFMailComposeResult.Saved:
            print("Mail saved")
        case MFMailComposeResult.Failed:
            print("Mail failed")
            
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: HumanBodyPartsViewController Protocol Methods
    
    func takeSelectedBodyPartToLoggerScreen(bodyPartName: String) {
        treatmentAreaButton.setTitle(bodyPartName, forState: .Normal)
    }
    
    //MARK: SYNCING
    func getUserDataIfPresent(completion : (isCompleted : Bool)->Void){
        
        
        PatientManager.deleteAlldataFromDB()
        
        let getUserDataUrl = ApiUrl.userDataSync
        
        let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")?.integerValue
        print(user_id)
        //Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1
        let header = ["authorization":"Basic YWRtaW46UVlpTkZOem5XeEZGZ2EyJlk1","contentType": "application/json"]
        
        let parameter : [String : AnyObject]? = ["user_id" : user_id!]
        print(parameter)
        
        LoginManager.getUserData(getUserDataUrl, parameter: parameter, header: header) { (isSuccessfullOrNot, apiResponseTaken, errorMessageTaken) in
            if isSuccessfullOrNot == true{
                let apiMessage = apiResponseTaken["msg"] as! String
                if apiMessage == "No Data"{
                    print("No User Data")
                    completion(isCompleted: true)
                }else{
                    let userData = apiResponseTaken["data"] as! NSArray
                    print(userData)
                    for individualRecord in userData{
                        print(individualRecord)
                        let recordDictionary = individualRecord as! NSDictionary
                        let preValue = (recordDictionary["pre"] as! NSString).integerValue
                        let postValue = (recordDictionary["post"] as! NSString).integerValue
                        let treatmentDuration = (recordDictionary["treatment_duration"] as! NSString).integerValue
                        let dateFromApi = recordDictionary["datetime"] as! String
                        let logDate = LoggerViewController.getDateTimeInNSDate(dateFromApi)
                        let indicationType = recordDictionary["indication_level"] as! String
                        let frequency = (recordDictionary["frequency"] as! NSString).doubleValue
                        let current = (recordDictionary["current"] as! NSString).doubleValue
                        let treatmentArea = recordDictionary["treatment_area"] as! String
                        
                        Logger.addHistory(preValue, postTreatmentPainLevel: postValue, treatmentDuration: treatmentDuration, Date: logDate, type: indicationType, frequency: frequency, current: current, treatmentArea: treatmentArea)
                    }
                    self.historyView?.refreshView()
                    
                    completion(isCompleted: true)
                }
            }
        }
        
    }
    
    
}

