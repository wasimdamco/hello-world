//
//  Graph.swift
//  EPIAL
//
//  Created by Akhil on 26/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
import CoreData

enum categoryTitle{
case pain
case insomnia
}
/**
 class: GraphViewController is the controller class that displays the graph on screeen. It uses the third party charts library "https://github.com/danielgindi/ios-charts". It is a ports of Android library MPAndroidChart to ios. The components from this library have been integrated into the project. This class implements the ChartViewDelegate to handle all delegate events of the class.
	CombinedChartView contains multiple charts and supports following charts for example, BarLineChartViewBase, LineChartDataProvider, BarChartDataProvider, ScatterChartDataProvider,
	CandleChartDataProvider, BubbleChartDataProvider.
	In this chart class we support 2 types of charts, bar chart and line chart. The bar chart is plotted against the right side y-axis and line chart is plotted against left side y-axis.
	All configuration settings for the chart are done under the function configureChart().
	Specific chart data for line chart and for bar chart is generated by functions generateLineData and generateBarData respectively.
 */

class GraphViewController: UIViewController,ChartViewDelegate {
    
    @IBOutlet weak var averageTreatmentDurationValueLabel: UILabel!
    @IBOutlet weak var averageChangeValueLabel: UILabel!
    @IBOutlet weak var averageTreatmentDurationLabel: UILabel!
    @IBOutlet weak var averageChangeTitleLabel: UILabel!
    @IBOutlet weak var averageParentView: UIView!
    @IBOutlet weak var legendSubView: UIView!
    @IBOutlet weak var treatmentDurationColor: UIImageView!
    @IBOutlet weak var painCategoryColor: UIImageView!
    @IBOutlet weak var painCategorytype: UILabel!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var chartView: CombinedChartView!
    
    @IBOutlet weak var prePostLegendViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var categories = ["Pain","Anxiety", "Insomnia", "Depression"]
    //var categories = [String]()
//    var loggerArray = [Logger]()
//    var loggerArrayCopy =  [Logger]()
    //  Mohit Change
    var loggerArray = [Average]()
    var loggerArrayCopy =  [Average]()
    var categoryAverage : String = ""
    var categorySelected : String?
    var averagetreatmentDuration : String = ""
    var categoryDataSource : [String] = []
    var categoryDataSourceBasic : [String] = []
    
    //Mohit Change
    var loggerArrayOriginal = [Logger]()
    
    
    override func viewDidLoad() {
        viewWillAppear(false)
        //legendView.hidden = true
        // Mohit change
        //customizeScrollView()
        treatmentDurationColor.backgroundColor = UIColor(red: 207 / 255.0, green: 150 / 255.0, blue: 53 / 255.0, alpha: 1.0)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("View will disappear , Graph")
//        self.loggerArray = []
//        self.loggerArrayCopy = []
//        
//        self.loggerArray = loggerArrayOriginal
//        loggerArrayCopy = loggerArrayOriginal
//        
//        print(loggerArrayOriginal)
//        print(loggerArray)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("View did disappear , Graph")
    }
    
    
    
    func manageLegendSubView() {
        if loggerArray.count > 0 {
            legendSubView.hidden = false
        }else{
            legendSubView.hidden = true
            
        }
    }
    
    func areTwoArraysEqual(firstArray : [String], secondArray : [String])-> Bool{
        
        var resultArray = [Bool]()
        
        if firstArray.count != secondArray.count{return false}else{
            for firstItemOfArray in firstArray{
                for secondItemOfArray in secondArray{
                    if firstItemOfArray == secondItemOfArray{
                        resultArray.append(true)
                    }
                }
            }
        }
        
        print(resultArray)
        
        if resultArray.contains(false){
        print("Working")
        }else{
        print("Not Working")
        }
        
        return false
    }
    
    func checkIfCategoryExixtsInDataSource(categorySelected : String , dataSourceCatagory : [String])-> Bool{
        var status : Bool = false
        for category in dataSourceCatagory{
            if category == categorySelected{
            status = true
            return status
            }
        }
        return status
    }
    
    override func viewWillAppear(animated: Bool) {
        //if let data: [Logger] = Logger.fetchAllHistory() {
        // for testing purpose
        
        
        if let dataSource = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
            categoryDataSource = dataSource
        }else{
            categoryDataSource = ["Pain","Anxiety", "Insomnia", "Depression"]
        }

        
        // Uncomment if you want to add the user device model validation on graph too i.e if user has the "Alpha-Stim AID" model then no pain category will be shown to user
     /**
        let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String
        if (userDeviceModel != nil) && (userDeviceModel == "Alpha-Stim AID"){
            if var dataSource = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
                
                for (index,item) in dataSource.enumerate(){
                    if item == "Pain"{
                        dataSource.removeAtIndex(index)
                    }
                }
                categoryDataSource = dataSource
            }else{
                categoryDataSource = ["Anxiety", "Insomnia", "Depression"]
            }
        }else{
            if var dataSource = NSUserDefaults.standardUserDefaults().valueForKey("categoryDataSource") as? [String]{
                categoryDataSource = dataSource
            }else{
                categoryDataSource = ["Pain","Anxiety", "Insomnia", "Depression"]
            }
        }
        
    **/    
        
        
        print(categoryDataSource)
        
        categories = []
        
        
        for items in categoryDataSource{
            if items != "Enter Custom Indication"{
                categories.append(items)
            }
        }
        
        categoryDataSourceBasic = categories
        
        if categorySelected != nil{
            if checkIfCategoryExixtsInDataSource(categorySelected!, dataSourceCatagory: categories) == true{
                customizeScrollView(categorySelected)
            }else{
                customizeScrollView(nil)
            }
        }else{
            customizeScrollView(nil)
        }

         print("View will appear , Graph")
        
        averageChangeValueLabel.hidden = true
        averageTreatmentDurationValueLabel.hidden = true
        
        if let data : [Logger] = Logger.fetchCompleteRecords(){
//            self.loggerArray = data
//            loggerArrayCopy = data
            // Mohit Change
            
//            loggerArrayOriginal = data
//            print(loggerArrayOriginal)
            
            self.loggerArray = makeArrayContainSingleRecordsAndAverageOfTwoRecords(data)
            loggerArrayCopy = self.loggerArray
            print(loggerArray)
            
            loggerArray = loggerArray.filter({ (logger) -> Bool in
                logger.categories == "Pain"
                
            })
            configureChart()
            if categorySelected != nil{
                switch categorySelected!{
                case "Pain":
                     setLabel("Pain Level", color: UIColor.redColor().colorWithAlphaComponent(0.35))
                case "Anxiety":
                     setLabel("Anxiety level", color: UIColor.greenColor().colorWithAlphaComponent(0.35))
                case "Insomnia":
                     setLabel("Insomnia level", color: UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 0.5))
                case "Depression":
                   setLabel("Depression level", color: UIColor.blueColor().colorWithAlphaComponent(0.35))
                default:
                    setLabel(categorySelected!, color: UIColor.yellowColor().colorWithAlphaComponent(0.35))
                }
                
            }else{
            setLabel("Pain Level", color: UIColor.redColor().colorWithAlphaComponent(0.35))
            }
            
            
            manageLegendSubView()
            if categorySelected != nil{
                
                 //Mohit change
                
//                switch categorySelected!{
//                case "Pain":
//                    loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
//                        logger.categories == "Pain"
//                    })
//                    configureChart()
//                    showAverageValues("Pain")
//                    break
//                case "Anxiety":
//                    loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
//                        logger.categories == "Anxiety"
//                    })
//                    configureChart()
//                    showAverageValues("Anxiety")
//                    break
//                case "Insomnia":
//                    loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
//                        logger.categories == "Insomnia"
//                    })
//                    configureChart()
//                    showAverageValues("Insomnia")
//                    break
//                case "Depression":
//                    loggerArray = loggerArrayCopy.filter({ $0.categories == "Depression"
//                    })
//                    configureChart()
//                    showAverageValues("Depression")
//                    break
//                    
//                default:
//                    print(title)
//                }
               
                
                for categoryTaken in categoryDataSource{
                    if categorySelected == categoryTaken{
                        loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
                            logger.categories == categoryTaken
                        })
                        configureChart()
                        showAverageValues(categoryTaken)
                        return
                    }
                }
                
                manageLegendSubView()
            }
            
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewWillAppear(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // prePostLegendViewLeadingConstraint.constant = CurrentDeviceType.IS_IPHONE_6 ? 35 : CurrentDeviceType.IS_IPHONE_5 ? 41 : CurrentDeviceType.IS_IPHONE_6P ? 35 : 35
    }
    
    func makeArrayContainSingleRecordsAndAverageOfTwoRecords(data : [Logger]) -> [Average]{
        
        Average.deleteAlldataFromAverageDB()
        
        let categoryArray = getCategoriesFromDataTaken(data)
        
        let datesArray = getDifferentDatesFromDataTaken(data)
        var loggerArrayUsedInGraph = [Average]()
        
        for eachCategory in categoryArray{
            
            for eachdate in datesArray{
                let categoryRecordsForDate = Logger.checkIfCompleteRecordCategoryExixtsInDB(eachdate, categoryInserted: eachCategory)
                if categoryRecordsForDate?.count == 2{
                    let record = findAverageOfRecords(categoryRecordsForDate!)
                    print(record)
                    //loggerArrayUsedInGraph.append(record)
                    //print(loggerArrayUsedInGraph)
                }else if categoryRecordsForDate?.count == 1{
                    let record = addRecordInAverageAndReturnAverageRecord((categoryRecordsForDate?.first)!)
                    print(record)
//                   loggerArrayUsedInGraph.append(record)
//                    print(loggerArrayUsedInGraph)
                }
            }
        }
        
        
        loggerArrayUsedInGraph = Average.fetchAverageAllHistory()!
        //Average.deleteAlldataFromAverageDB()
        
        print(loggerArrayUsedInGraph)
        return loggerArrayUsedInGraph
    }
    
    func addRecordInAverageAndReturnAverageRecord(object : Logger)-> Average{
    
         //Average.deleteAlldataFromAverageDB()
        
         Average.addRecordToAverage((object.preTreatmentPainLevel?.doubleValue)!, postTreatmentPainLevel:  (object.postTreatmentPainLevel?.doubleValue)!, treatmentDuration: (object.treatmentDuration?.doubleValue)!, Date: object.dateTime!, type: object.categories!, frequency: (object.frequency?.doubleValue)!, current: (object.current?.doubleValue)!, treatmentArea: object.treatmentArea!)
        
        let averageRecord = Average.fetchAverageAllHistory()
        
        return (averageRecord?.first)!
        
    }
    
    func findAverageOfRecords(records : [Logger])->Average{
        
        let recordsBefore = Logger.fetchAllHistory()
        print(recordsBefore)
        
        let firstRecord = records[0]
        
        let secondRecord = records[1]
        
        let preAverage = findAverage((firstRecord.preTreatmentPainLevel?.doubleValue)!, secondValue: (secondRecord.preTreatmentPainLevel?.doubleValue)!)
        print(preAverage)
        
        let postAverage = findAverage((firstRecord.postTreatmentPainLevel?.doubleValue)!, secondValue: (secondRecord.postTreatmentPainLevel?.doubleValue)!)
        print(postAverage)
        
        let treatmentDurationAverage = findAverage((firstRecord.treatmentDuration?.doubleValue)!, secondValue: (secondRecord.treatmentDuration?.doubleValue)!)
        print(treatmentDurationAverage)
        
        let frequencyTaken = firstRecord.frequency?.doubleValue
        
        let currentTaken = firstRecord.current?.doubleValue
        
       // Average.deleteAlldataFromAverageDB()
        
        Average.addRecordToAverage(preAverage, postTreatmentPainLevel:  postAverage, treatmentDuration: treatmentDurationAverage, Date: firstRecord.dateTime!, type: firstRecord.categories!, frequency: frequencyTaken!, current: currentTaken!, treatmentArea: firstRecord.treatmentArea!)
        
        
        let averageRecord = Average.fetchAverageAllHistory()
        
        let recordsAfter = Logger.fetchAllHistory()
        print(recordsAfter)
        
        return (averageRecord?.first)!
        
    }
    
    func findAverage(firstValue : Double , secondValue : Double)->Double{
        
        var average :Double = 0.0
    
        average = (firstValue + secondValue)/2
        print(average)
        return average
    }
    
    func getCategoriesFromDataTaken(dataInDB : [Logger]) -> [String]{
        
        var categoriesInDB = [String]()
        for record in dataInDB{
            if categoriesInDB.contains(record.categories!){
                // Category already in array
            }else{
                categoriesInDB.append(record.categories!)
            }
        }
        return categoriesInDB
    }
    
    func getDifferentDatesFromDataTaken(dataInDB : [Logger]) -> [NSDate]{
        
        var differentDatesInDB = [NSDate]()
        var stringDateArray = [String]()
        for record in dataInDB{
            if stringDateArray.contains(record.dateWithoutTime!){
                // Category already in array
            }else{
                stringDateArray.append(record.dateWithoutTime!)
                differentDatesInDB.append(record.dateTime!)
            }
        }
        return differentDatesInDB
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
 **/
        
        self.logoutPressed()
    }
    
    //MARK: PRIVATE METHODS
    func getAverageValues(ofCategory : String)-> String?{
        var prePostDifferenceValues = [Int]()
        prePostDifferenceValues = []
        var categoryAverage :Float?
        var allValuesAddition : Int?
        if let allrecords = Logger.fetchCompleteRecordsContainingAllFieldsFilled(){
            for records in allrecords{
                
                if records.categories == ofCategory{
                    print(records)
                    prePostDifferenceValues.append(findDifference(Int(records.preTreatmentPainLevel!), postValue: Int(records.postTreatmentPainLevel!)))
                }
            }
        }else{
            //No records present
        }
        
        //Find averageValue
        if  prePostDifferenceValues.count > 0{
            allValuesAddition = sumOfAllValues(prePostDifferenceValues)
            categoryAverage = Float(allValuesAddition!)/Float(prePostDifferenceValues.count)
            return String(categoryAverage!)
        }
        
        return nil
    }
    
    func getAverageTreatmentDuration(ofCategory : String)-> String?{
        var treatmentDurationArray = [Int]()
        treatmentDurationArray = []
        var allValuesAddition : Int?
        var averageTreatmentDuration : Float?
        if let completeRecords = Logger.fetchCompleteRecords(){
            for individualRecord in completeRecords{
                if individualRecord.categories == ofCategory{
                    treatmentDurationArray.append(Int(individualRecord.treatmentDuration!))
                }
            }
        }else{
        // No complete records present
        }
        
        if treatmentDurationArray.count > 0{
            allValuesAddition = sumOfAllValues(treatmentDurationArray)
            averageTreatmentDuration = Float(allValuesAddition!)/Float(treatmentDurationArray.count)
            return String(averageTreatmentDuration!)
        }
        
        return nil
    }
    
    func findDifference(prevalue : Int , postValue : Int) -> Int{
        let difference =  postValue - prevalue
        return difference
    }
    
    func sumOfAllValues(allValues : [Int])-> Int{
        var sum : Int = 0
        for value in allValues{
            sum = sum + value
        }
        return sum
    }
    
    func settingLegendConstraint(){
        prePostLegendViewLeadingConstraint.constant = CurrentDeviceType.IS_IPHONE_6 ? 35 : CurrentDeviceType.IS_IPHONE_5 ? 40 : 50
    }
    
    
    
    // MARK: Configuration
    /** Function to set configurations for the chart to display bar data and line data. You can customize the color of bars and line as well as circles that are displayed on screen.
     We also set the background color of the chart and other settings that can configure the complete chart view. If any of the settings are changed the same can be seen on chart displaying the
     data. This method is called via viewWillAppear() so that every time the chart gets loaded with changed and updated data.
     */
    func configureChart() {
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView._maxVisibleValueCount = 5
        chartView.backgroundColor = UIColor(red: 231.0 / 255.0, green: 231.0 / 255.0, blue: 231.0 / 255.0, alpha: 1.0)
        
        let formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.allowsFloats = false

        
        // set axis data
        let rightAxis: ChartYAxis = chartView.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.customAxisMax = 150
        rightAxis.labelCount = 15
        rightAxis.valueFormatter = formatter
        
        let leftAxis: ChartYAxis = chartView.leftAxis
        leftAxis.drawGridLinesEnabled = false
        leftAxis.customAxisMax = 10
        leftAxis.labelCount = 10
        leftAxis.valueFormatter = formatter
        
        
        let xAxis: ChartXAxis = chartView.xAxis
        xAxis.labelPosition = .Bottom
        xAxis.spaceBetweenLabels = 1
        xAxis.drawGridLinesEnabled = false
       
        
        let data: CombinedChartData = CombinedChartData(xVals: generateXAxisData())
        chartView.drawBarShadowEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawHighlightArrowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.descriptionText = ""
        chartView.scaleYEnabled = false
        chartView.legend.enabled = true
        // for scaling the chart view
        //				chartView.setScaleMinima(1.0, scaleY: 1.0)
        // sets the mainimum and maximum valuesx that can be plotted without scrolling.
        chartView.setVisibleXRange(minXRange: 0.0, maxXRange: 5.0)
        
        data.lineData = self.generateLineData()
        data.barData = self.generateBarData()
        self.chartView.data = data
        
        
    }
    
    // MARK: Data generator
    
    /** Function returns LineChartData type value. This value contains complete plott values for Line Graph creation. This vaue is assigned to CombinedChartData line data property for plotting on graph. The function also allows to set various line graph properties like line width, circle color, drawing of grid lines etc. From here you can also set the y-axis against which the graph needs to be plotted. ChartDataEntry is the class whose object capyures the actual value that needs to be plotted. The array of ChartDataEntry is fed to LineChartData array for displaying all plot values.
     */
    func generateLineData() -> LineChartData {
        let d: LineChartData = LineChartData()
        var circleColors = [UIColor]()
        var entries: [ChartDataEntry] = [ChartDataEntry]()
        print("logger array \(loggerArray)")
        
        //LineChartRenderer.setDeltaForMoreThanOneValue(loggerArray.count)
        
        NSUserDefaults.standardUserDefaults().setInteger(loggerArray.count, forKey: "deltaForMoreThanOneValue")
        
        for index in 0..<loggerArray.count{
            
            let logger = self.loggerArray[index]
            entries.append(ChartDataEntry(value: (logger.preTreatmentPainLevel?.doubleValue)!, xIndex: index))
            circleColors.append(UIColor.redColor())
            entries.append(ChartDataEntry(value: (logger.postTreatmentPainLevel?.doubleValue)!, xIndex: index))
            circleColors.append(UIColor.greenColor())
        }
        
        var set : LineChartDataSet
        
        if categorySelected == nil{
            set = LineChartDataSet(yVals: entries, label: "Pain Level")
        }else{
            set = LineChartDataSet(yVals: entries, label: "\(categorySelected!) Level")
        }
        //let set: LineChartDataSet = LineChartDataSet(yVals: entries, label: "Pain Level")
        
        switch set.label!{
        case "Pain Level":
            set.setColor(UIColor.redColor().colorWithAlphaComponent(0.35))
        case "Insomnia Level":
            set.setColor(UIColor(red: 218/255, green: 165/255, blue: 32/255, alpha: 0.5))
        case "Anxiety Level":
            set.setColor(UIColor.greenColor().colorWithAlphaComponent(0.35))
        case "Depression Level":
            set.setColor(UIColor.blueColor().colorWithAlphaComponent(0.35))
        default:
            print("")
        }

        // set.setColor(UIColor(red: 65 / 255.0, green: 71 / 255.0, blue: 135 / 255.0, alpha: 1.0))
        set.lineWidth = 2.5
        set.circleColors = circleColors
        set.fillColor = UIColor(red: 65 / 255.0, green: 71 / 255.0, blue: 135 / 255.0, alpha: 1.0)
        set.drawCubicEnabled = false
        set.drawValuesEnabled = true
        set.valueFont = UIFont.systemFontOfSize(10.0)
        set.valueTextColor = UIColor.clearColor()
        set.axisDependency = .Left
         d.addDataSet(set)
        return d
    }
    
    /** Function returns BarChartData type value. This value contains complete plott values for Bar Graph creation. This vaue is assigned to CombinedChartData bar data property for plotting on graph. From here you can also set the y-axis against which the graph needs to be plotted. ChartDataEntry is the class whose object capyures the actual value that needs to be plotted. The array of ChartDataEntry is fed to LineChartData array for displaying all plot values. The "barSpace" property is used to set the ratio of space between the bars relative to the width of graph.
     */
    func generateBarData() -> BarChartData {
        let d: BarChartData = BarChartData()
        var entries: [BarChartDataEntry] = [BarChartDataEntry]()
        // for var index = 0; index < self.loggerArray.count; index++ {
        for index in 0..<loggerArray.count{
            let logger = self.loggerArray[index]
            entries.append(BarChartDataEntry(value: (logger.treatmentDuration?.doubleValue)!, xIndex: index))
            
        }
        
        let set: BarChartDataSet = BarChartDataSet(yVals: entries, label: "")
        set.setColor(UIColor(red: 207 / 255.0, green: 150 / 255.0, blue: 53 / 255.0, alpha: 1.0))
        set.valueTextColor = UIColor.clearColor()
        set.valueFont = UIFont.systemFontOfSize(10.0)
        set.axisDependency = .Right
        
        set.barSpace = 0.50
        
        d.addDataSet(set)
        
        return d
    }
    
    /** Function returns the array of string that needs to be set on x-axis of the graph. Here date from logs history is used as plot value. The format of date is set to "dd/MM" and it can be changed here.
     */
    func generateXAxisData() -> [String] {
        var entries: [String] = [String]()
        //for var index = 0; index < self.loggerArray.count; index++ {
        for index in 0..<loggerArray.count{
            let logger = self.loggerArray[index]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MMM"
            let logDate = dateFormatter.stringFromDate(logger.dateTime!)
            entries.append(logDate)
        }
        return entries
    }
    
    func customizeScrollView(categorySelected : String?){
        
        for view in scrollView.subviews {
           if view .isKindOfClass(UIButton){
           view.removeFromSuperview()
           }
        }
        let buttonWidth:Int =  100
        let buttonHeight:CGFloat =  30
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize =  CGSizeMake(CGFloat(buttonWidth*categories.count),50)
        scrollView.backgroundColor  = UIColor(patternImage: UIImage(named: "backgroundScrolll.png")!)
        for i in 0 ..< categories.count {
            let button = UIButton(frame: CGRectMake(CGFloat(i*buttonWidth),10,CGFloat(buttonWidth),buttonHeight))
            button.setTitle(categories[i], forState: .Normal)
            button.titleLabel?.font =  UIFont(name: "ProximaNova-Semibold", size: 16)
            button.setTitleColor(UIColor(hexString: "6B8386"), forState: .Normal)
            button.addTarget(self, action: #selector(GraphViewController.onClickAction(_:)), forControlEvents: .TouchUpInside)
            

            if categorySelected != nil{
                
                if categories[i] == categorySelected{
                    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    button.layer.cornerRadius = 15
                    button.backgroundColor = UIColor(hexString: "6B8386")
                    loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
                        logger.categories == categorySelected
                    })
                    configureChart()
                    showAverageValues(categorySelected!)
                    manageLegendSubView()

                }
                
            }else{
                //Default selection button
                if i == 0{
                    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                    button.layer.cornerRadius = 15
                    button.backgroundColor = UIColor(hexString: "6B8386")
                    loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
                        logger.categories == "Pain"
                    })
                    configureChart()
                    showAverageValues("Pain")
                    manageLegendSubView()
                }
            }

            scrollView.addSubview(button)
        }
        
        
        
    }
    
    func showAverageValues(ofCategory : String){
    
        categoryAverage = ""
        averagetreatmentDuration = ""
        
        if let categoryAverageTaken = getAverageValues(ofCategory){
            categoryAverage = categoryAverageTaken
        }
        print(categoryAverage)
        if let averagetreatmentDurationTaken = getAverageTreatmentDuration(ofCategory){
            averagetreatmentDuration = averagetreatmentDurationTaken
        }
        print(averagetreatmentDuration)
    
        
        if categoryAverage.characters.count>0 {
            let lowercaseCategory = ofCategory.lowercaseString
            averageChangeTitleLabel.text = "Average change of \(lowercaseCategory) level: \(categoryAverage)"
            averageChangeValueLabel.text =  ": " + categoryAverage
        }
        
        if averagetreatmentDuration.characters.count > 0{
            averageTreatmentDurationLabel.text = "Average treatment duration: \(averagetreatmentDuration)"
            averageTreatmentDurationValueLabel.text = ": " + averagetreatmentDuration
        }
        
         managingTheAverageViews()
    }
    
    func managingTheAverageViews(){
        if categoryAverage.characters.count <= 0 && averagetreatmentDuration.characters.count <= 0{
            //Hiding the view showing average values
            averageParentView.hidden = true
        }else{
            averageParentView.hidden = false
        }
        
        // Hiding the average treatment duration if it is nil
        if averagetreatmentDuration.characters.count <= 0 {
            averageTreatmentDurationLabel.hidden = true
            averageTreatmentDurationValueLabel.hidden = true
        }else{
            averageTreatmentDurationLabel.hidden = false
           // averageTreatmentDurationValueLabel.hidden = false
        }
        
        // Hiding the average category value if it is nil
        if categoryAverage.characters.count <= 0 {
            averageChangeTitleLabel.hidden = true
            averageChangeValueLabel.hidden = true
        }else{
            averageChangeTitleLabel.hidden = false
            //averageChangeValueLabel.hidden = false
        }

    }
    
    
    func onClickAction(sender:UIButton){
        //filter the  loggerArray
        
        for view in scrollView.subviews{
            if view.isKindOfClass(UIButton){
                (view as! UIButton).setTitleColor(UIColor(hexString: "6B8386"), forState: .Normal)
                (view as! UIButton).backgroundColor = UIColor.clearColor()
            }
        }
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sender.layer.cornerRadius = 15
        
        sender.backgroundColor = UIColor(hexString: "6B8386")
        
        categorySelected = sender.titleLabel?.text
        
        for diseases in categoryDataSource{
            if diseases == sender.titleLabel?.text{
                loggerArray = loggerArrayCopy.filter({ (logger) -> Bool in
                    logger.categories == diseases
                })
                configureChart()
                showAverageValues(diseases)
                setLabel("\(diseases) level", color: UIColor.greenColor().colorWithAlphaComponent(0.35))
                manageLegendSubView()
                return
            }
            
        }
        
        manageLegendSubView()
        
    }
    
    func setLabel(text : String, color : UIColor){
        painCategorytype.text = text
        painCategoryColor.backgroundColor = color
    }
    
}