//
//  AnalysisViewController.swift
//  EPIAL
//
//  Created by User on 22/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {

    @IBOutlet weak var noUserDataViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var sectionInTable = [String]()
    var percentChangeOfCategoriesDataSource = [String]()
    var treatmentDurationOfCategoriesDataSource = [String]()
    var percentImprovementForAllUsersDataSource = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Register TableViewCell
        registerTableViewCell("AnalysisCell")
        registerTableViewCell("AnalysisSectionViewCell")

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Get categories present in DB
        sectionInTable = getCategoriesFromDB()
        print(sectionInTable)
        
//        percentChangeOfCategoriesDataSource = []
//        treatmentDurationOfCategoriesDataSource = []
        
        //createDataSource()
        
        if sectionInTable.count > 0 {
            noUserDataViewLabel.hidden = true
            percentImprovementForAllUsersDataSource = []
            treatmentDurationOfCategoriesDataSource = []
            recursiveData(sectionInTable)
        }else{
            noUserDataViewLabel.hidden = false
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func registerTableViewCell(identifier : String){
        let tableCellNib = UINib(nibName: identifier, bundle: nil)
        tableView.registerNib(tableCellNib, forCellReuseIdentifier: identifier)
    }

    
    func createDataSource(){
        //Created percent average for each category present in dataBase.
            percentChangeOfCategoriesDataSource = []
            treatmentDurationOfCategoriesDataSource = []
        
        for items in sectionInTable{
            percentChangeOfCategoriesDataSource.append(getPercentValues(items,percentage: true)!)
            treatmentDurationOfCategoriesDataSource.append(getAverageTreatmentDuration(items ,sum: true)!)
        }
        
       print(percentChangeOfCategoriesDataSource)
        print(sectionInTable)
        sectionInTable = getCategoriesFromDB()
        tableView.reloadData()
    }
    
    
    
    func getdataSource(completion : (isFinished : Bool)-> Void){
        
       
       // treatmentDurationOfCategoriesDataSource = []
        
        Spinner.show("Loading..")
        for items in sectionInTable{
            PatientManager.getAllUsersIndicationdata(items) { (averageTreatmentDuration, percentImprovementAllUsers) in
                self.percentImprovementForAllUsersDataSource.append(percentImprovementAllUsers)
              //  self.treatmentDurationOfCategoriesDataSource.append(averageTreatmentDuration)
                
            }
        }
        
        print(percentImprovementForAllUsersDataSource)
        print(treatmentDurationOfCategoriesDataSource)
       // self.tableView.reloadData()
        completion(isFinished: true)
        

    }
    
    
    func recursiveData(dataSource : [String]){
    
    
        Spinner.show("Loading")
        sectionInTable = []
        var dataArray = [String]()
        dataArray = dataSource
        let firstElement = dataArray.first
        print("firstElement",firstElement)
        PatientManager.getAllUsersIndicationdata(firstElement!) { (averageTreatmentDuration, percentImprovementAllUsers) in
            self.percentImprovementForAllUsersDataSource.append(percentImprovementAllUsers)
            self.treatmentDurationOfCategoriesDataSource.append(averageTreatmentDuration)
            dataArray.removeAtIndex(0)
            if(dataArray.count == 0){//AllDone
               Spinner.hide()
                self.sectionInTable = self.getCategoriesFromDB()
                print(self.sectionInTable)
                self.createDataSource()
                //self.tableView.reloadData()
            }else{
                self.recursiveData(dataArray)
            }
            
        }
        
    }
    
    func getCategoriesFromDB() -> [String]{
        
        sectionInTable = []
        
       // let DBData = Logger.fetchAllHistory()
        
        let DBData = Logger.fetchCompleteRecordsContainingAllFieldsFilled()
        var categoriesInDB = [String]()
        
        if let dataInDB = DBData{
            for record in dataInDB{
                if categoriesInDB.contains(record.categories!){
                    // Category already in array
                }else{
                    categoriesInDB.append(record.categories!)
                }
            }
        }else{
                print("No Data In DB")
        }
        
        return categoriesInDB
    }
    
    func getPercentValues(ofCategory : String , percentage : Bool)-> String?{
        var prePostDifferenceValues = [Float]()
        prePostDifferenceValues = []
        var categoryPercentAverage :Float?
        var allValuesAddition : Float?
        if let allrecords = Logger.fetchCompleteRecordsContainingAllFieldsFilled(){
            for records in allrecords{
                print(records.categories)
                if records.categories == ofCategory{
                    if percentage == true{
                        prePostDifferenceValues.append(findPercentDifference(Int(records.preTreatmentPainLevel!), postValue: Int(records.postTreatmentPainLevel!)))
                    }else{
                        prePostDifferenceValues.append(findDifference(Int(records.preTreatmentPainLevel!), postValue:  Int(records.postTreatmentPainLevel!)))
                    }
                    
                }
            }
        }else{
            //No records present
            prePostDifferenceValues = []
        }
        
        //Find averageValue
        if  prePostDifferenceValues.count > 0{
            allValuesAddition = sumOfAllValues(prePostDifferenceValues)
            if percentage == true{
            categoryPercentAverage = (Float(allValuesAddition!)/Float(prePostDifferenceValues.count))*100.0
            }else{
            categoryPercentAverage = Float(allValuesAddition!)/Float(prePostDifferenceValues.count)
            }
            print(prePostDifferenceValues)
            prePostDifferenceValues = []
            return String(format: "%.1f",categoryPercentAverage!)
        }
        
        return nil
    }

    func findPercentDifference(prevalue : Int , postValue : Int) -> Float{
        let calculation =  Float(postValue - prevalue)/Float(prevalue)
        print(calculation)
        return calculation
    }
    
    func findDifference(prevalue : Int , postValue : Int) -> Float{
        let difference =   Float(postValue - prevalue)
        return difference
    }
    

    
    func sumOfAllValues(allValues : [Float])-> Float{
        var sum : Float = 0
        for value in allValues{
            sum = sum + value
        }
        
        return sum
    }
    
    func getAverageTreatmentDuration(ofCategory : String, sum : Bool)-> String?{
        var treatmentDurationArray = [Float]()
        treatmentDurationArray = []
        var allValuesAddition : Float?
        var averageTreatmentDuration : Float?
        if let completeRecords = Logger.fetchCompleteRecords(){
            for individualRecord in completeRecords{
                if individualRecord.categories == ofCategory{
                    treatmentDurationArray.append(Float(individualRecord.treatmentDuration!))
                }
            }
        }else{
            // No complete records present
            treatmentDurationArray = []
        }
        
        if treatmentDurationArray.count > 0{
            allValuesAddition = sumOfAllValues(treatmentDurationArray)
            averageTreatmentDuration = Float(allValuesAddition!)/Float(treatmentDurationArray.count)
            treatmentDurationArray = []
            // Return averageTreatmentDuration if you want to return the average and return allValuesAddition to return the sum
            if sum == true{
                return String(format: "%.0f",allValuesAddition!)
            }else{
                return String(format: "%.1f",averageTreatmentDuration!)
            }
            
            
        }
        
        return nil
    }
    
    
    
    

    
    // MARK: MOHIT FREQUECY WORK
    func getMostEffectiveFrequency(ofCategory : String)-> String?{
        
        let completeData = Logger.fetchCompleteRecords()
        var data = [Logger]()
        
        for individualData in completeData!{
            if individualData.categories == ofCategory{
                data.append(individualData)
            }
        }
        
        
        if data.count > 0{
            var dictionaryOFchangeAndfrequency = [[Double : Double]]()
            
            for items in data
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
    
    
    
    // MARK: MOHIT CURRENT WORK
    
    func getMostEffectiveCurrent(ofCategory : String)-> String?{
        
        let completeData = Logger.fetchCompleteRecords()
        var data = [Logger]()
        
        for individualData in completeData!{
            if individualData.categories == ofCategory{
                data.append(individualData)
            }
        }
        
        
        
        if data.count > 0{
            var dictionaryOFchangeAndCurrent = [[Double : Double]]()
            
            for items in data
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

    
    @IBAction func logoutPressed(sender: UIButton) {
        self.logoutPressed()
    }
    
    
}

extension AnalysisViewController : UITableViewDataSource, UITableViewDelegate{

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionInTable.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let analysisCell = tableView.dequeueReusableCellWithIdentifier("AnalysisCell") as! AnalysisCell
        print("percentImprovementForAllUsersDataSource",percentImprovementForAllUsersDataSource)
       
        analysisCell.selectionStyle = .None
        
        var currentValue : String?
        var frequencyValue : String?
        
        if let currentValueFromFunction = self.getMostEffectiveCurrent(sectionInTable[indexPath.section]){
            currentValue = currentValueFromFunction
            print(currentValue!)
            analysisCell.mostEffectiveCurrentValue.text = "\(currentValue!) µA"
            NSUserDefaults.standardUserDefaults().setObject(Float(currentValueFromFunction), forKey: "effectiveCurrent")
        }else{
            analysisCell.mostEffectiveCurrentValue.text = ""
        }
        
        if let frequencyValueFromFunction = self.getMostEffectiveFrequency(sectionInTable[indexPath.section]){
            frequencyValue = frequencyValueFromFunction
            analysisCell.mostEffectFrequencyValue.text = " \(frequencyValue!) Hz"
            NSUserDefaults.standardUserDefaults().setObject(Float(frequencyValueFromFunction), forKey: "effectiveFrequency")
        }else{
            analysisCell.mostEffectFrequencyValue.text = ""
        }
        
        let percentChangeValue = percentChangeOfCategoriesDataSource[indexPath.section]
        
        if percentChangeValue == "nan"{
            analysisCell.categoryTitleValue.text = "0 %"
        }else{
            analysisCell.categoryTitleValue.text = percentChangeValue + " %"
        }
        
         analysisCell.categoryTitle.text = "Percent Improvement In \(sectionInTable[indexPath.section])"
         analysisCell.allUsersTitle.text = "Percent Improvement All Users"
         analysisCell.treatmentDurationTitle.text = "Cumulative Timer"
         analysisCell.treatmentDurationValue.text = treatmentDurationOfCategoriesDataSource[indexPath.section] + " mins"
         analysisCell.allUsersValue.text = percentImprovementForAllUsersDataSource[indexPath.section] 

        return analysisCell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionCell = tableView.dequeueReusableCellWithIdentifier("AnalysisSectionViewCell") as! AnalysisSectionViewCell
        sectionCell.titleLabel.text = sectionInTable[section]
        return sectionCell
        
    }
    
   
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 302
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8.0
    }
}
