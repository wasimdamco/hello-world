
//
//  EPHistoryTableView.swift
//  EPIAL
//
//  Created by Juli on 18/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
import CoreData

//MARK: PROTOCOL METHOD
protocol takeTableViewData{
    func getData(log : Logger)
}

/**
Class: EPHistoryTableView: This class is subclass of UIView and is used to maintain/ display logs that user has recorded. It has implementation for UITableViewDataSource and UITableViewDelegate methods. The user can swipe left on the table view cell to remove/ delete the recorded value.
*/

class EPHistoryTableView: UIView, UITableViewDataSource,UITableViewDelegate {

	@IBOutlet weak var historyTable: UITableView!
	var dataSource: [Logger] = []
    var delegate : takeTableViewData?
    var selectedRow : Int = -1
	
	class func initWithNib()-> AnyObject? {
		
		let nibChilds = NSBundle.mainBundle().loadNibNamed("EPHistoryTableView", owner: nil, options: nil)
		var table: EPHistoryTableView?
		for nibView in nibChilds! {
			if nibView .isKindOfClass(EPHistoryTableView){
				table = nibView as? EPHistoryTableView
			}
		}
		return table
	}
    
    
	
	/**
	function to refreash the table data list
	and reload table.
	*/
	func refreshView() {
		dataSource = Logger.fetchAllHistory()!
        print(dataSource.count)
        print(dataSource)
        
        var a : [Logger] = []
        for items in dataSource{
       //     print(items.categories)
            a.append(items)
        }
        
        print(a)
        
        selectedRow = -1
        
        if dataSource.count == 0{
            historyTable.separatorStyle = .None
        }else{
            historyTable.separatorStyle = .SingleLine
        }

            historyTable.reloadData()
        
        if ((self.nextResponder()?.isKindOfClass(LoggerViewController)) != nil)
        {
            //Mohit Gaur : Fix: get parent controller
            print("logger reset")
            let loggerVC = self.nextResponder() as? LoggerViewController
            
            loggerVC?.resetValues()
        }
	}
    
    func showSelectedcell( objectId: NSManagedObjectID){
        //predicate in dataSource
        var i = 0
        for items in dataSource{
             i += 1
            if items.objectID == objectId{
                selectedRow = i - 1
                historyTable.reloadData()
                
                //move to rect
                //historyTable.scrollRectToVisible(CGRectMake(0, CGFloat(selectedRow*110), historyTable.frame.width, 110), animated: true)
                historyTable.scrollToRowAtIndexPath(NSIndexPath(forRow: selectedRow, inSection: 0), atScrollPosition: .Top, animated: true)
                
            }
        }
        
       }
	
    //MARK: TABLEVIEW DATASOURCE METHODS
	// UITable dataSource method
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		// Remove seperator inset
		if cell.respondsToSelector(Selector("setSeparatorInset:")) {
			cell.separatorInset = UIEdgeInsetsZero
		}
		// Prevent the cell from inheriting the Table View's margin settings
		if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
			cell.preservesSuperviewLayoutMargins = false
		}
		// Explictly set your cell's layout margins
		if cell.respondsToSelector(Selector("setLayoutMargins:")) {
			cell.layoutMargins = UIEdgeInsetsZero
		}
		tableView.allowsSelection = true
	}
	// UITable dataSource method
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if dataSource.count > 0 {
			return dataSource.count
		}
		else{
			return 0
		}
	}
	// UITable dataSource method
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell: EPHistoryTableViewCell?   = tableView.dequeueReusableCellWithIdentifier("CustomCell") as? EPHistoryTableViewCell
		if cell == nil
		{
			let nib: NSArray = NSBundle.mainBundle().loadNibNamed("EPHistoryTableViewCell", owner: self, options: nil)!
			cell = nib.objectAtIndex(0) as? EPHistoryTableViewCell
		}
        
        // Making fields null so that it doesn't show any previous data when cell is reused.
        cell?.painLevelLabel.text = ""
        cell?.dateTimeValue.text = ""
        cell?.preTreatmentLevelValue.text = ""
        cell?.postTreatmentLevelValue.text = ""
        cell?.treatmentDurationValue.text = ""
        cell?.typeValue.text = ""
        cell?.frequencyValue.text = ""
        cell?.currentValue.text = ""
        cell?.treatmentAreaValue.text = ""
        
        
        cell?.contentView.backgroundColor = nil
		if indexPath.row % 2 == 0 {
			let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, (cell?.frame.size.width)!, (cell?.frame.size.height)!))
			imageView.image = UIImage(named: "Rowstrip")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch)
			cell?.backgroundView = imageView
		} else {
			cell?.backgroundView = nil
		}
        
        let log: Logger = dataSource[indexPath.row]
        if log.categories != nil{
            cell?.painLevelLabel.text = log.categories! + " level"
        }else{
            cell?.painLevelLabel.text = ""
        }
        
    
    
//        if log.preTreatmentPainLevel?.stringValue.characters.count == 1{
//            cell?.preTreatmentLevelValue.text = "0\(log.preTreatmentPainLevel!)"
//        }else{
//            cell?.preTreatmentLevelValue.text = log.preTreatmentPainLevel?.stringValue
//        }
        
        // Mohit change

        cell?.preTreatmentLevelValue.text = log.preTreatmentPainLevel?.stringValue
        
        if log.postTreatmentPainLevel == nil || log.postTreatmentPainLevel == ""{
            cell?.postLabel.hidden = true
            cell?.separatorLabel.hidden = true
           // cell?.postTreatmentLevelValue.hidden = true
            
        }else{
            //cell?.postTreatmentLevelValue.hidden = false
            cell?.postLabel.hidden = false
            cell?.separatorLabel.hidden = false
            
//            if log.postTreatmentPainLevel?.stringValue.characters.count == 1{
//                cell?.postTreatmentLevelValue.text = "0\(log.postTreatmentPainLevel!)"
//            }else{
//                cell?.postTreatmentLevelValue.text = log.postTreatmentPainLevel?.stringValue
//            }

        // Mohit change
            
            cell?.postTreatmentLevelValue.text = log.postTreatmentPainLevel?.stringValue
        
        }
        
        if log.treatmentDuration == nil || log.treatmentDuration == " "{
            cell?.treatmentDurationValue.text = ""
          //  cell?.treatmentDurationValue.text = (log.treatmentDuration?.stringValue)! + " mins"
        }else{
            cell?.treatmentDurationValue.text = ""
             cell?.treatmentDurationValue.text = (log.treatmentDuration?.stringValue)! + " mins"
        }
        
		cell?.dateTimeValue.text = getDateTimeInString(log.dateTime!)
		cell?.typeValue.text = log.categories
        
        if log.current != nil{
            cell?.currentValue.text = (log.current?.stringValue)! + " µA"
        }else{
            cell?.currentValue.text = ""
        }
        
        if log.frequency != nil{
            cell?.frequencyValue.text = (log.frequency?.stringValue)! + " Hz"
        }else{
            cell?.frequencyValue.text = ""
        }
        
        
        if log.treatmentArea == ""{
            cell?.treatmentAreaValue.hidden = true
            cell?.treatmentAreaTitleLabel.hidden = true
        }else{
            cell?.treatmentAreaTitleLabel.hidden = false
            cell?.treatmentAreaValue.hidden = false
            cell?.treatmentAreaValue.text = log.treatmentArea
        }
        
        
		cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        if  selectedRow == indexPath.row{
        cell?.contentView.backgroundColor = UIColor.grayColor()
        }
        
		return cell!
	}
	
	// UITable method to allow table in edit mode
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		return true
	}
	// UITable method to delete row from table on delete button action
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            // Mohit Change
            //removeObjectAtIndex(indexPath.row)
        
            if ((self.parentViewController?.isKindOfClass(LoggerViewController)) != nil){
                let logVC =   self.parentViewController as? LoggerViewController
                
                logVC?.disableButtons(false)
                let valueName = dataSource[indexPath.row].categories
                removeObjectAtIndex(indexPath.row)
                logVC?.manageEffectiveValues()
                if valueName == "Pain" || valueName == "Depression" || valueName == "Anxiety" || valueName == "Insomnia" {
                    // Do nothing
                }else{
                    if ifCategoryExixtsInDatabase(valueName!){
                        // it means the database still contains some custom indication value
                    }else{
                        let categoryList = logVC?.typesOfDiseasesDataSource
                        for i  in 0..<categoryList!.count{
                            if categoryList![i] == valueName{
                                logVC?.typesOfDiseasesDataSource[i] = "Enter Custom Indication"
                               NSUserDefaults.standardUserDefaults().setObject(logVC?.typesOfDiseasesDataSource, forKey: "categoryDataSource")
                                print(logVC?.typesOfDiseasesDataSource)
                            }
                        }
                    }
                }
                
                logVC?.resetValues()
                SyncManager.syncData(true)
            }
            
        }
    }

	
    func ifCategoryExixtsInDatabase(categoryDeleted : String)-> Bool{
        let allRecords = Logger.fetchAllHistory()
        var status : Bool = false
        for individualrecords in allRecords!{
            print(individualrecords)
            if individualrecords.categories == categoryDeleted{
                    status  = true
            }
        }
        return status
    }

       
    
    //MARK: TABLEVIEW DELEGATE METHODS
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    print("Tapped")
        let log: Logger = dataSource[indexPath.row]
        delegate?.getData(log)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: PRIVATE METHODS
    /**
     Function to remove item from selected index of table datasource.
     The function calls the deleteHistory method of Logger entity class
     and pass the selected logger instance object to be deleted from
     entity. And then refreashView function is called.
     :parameter: index: Index of selected item from table.
     */
    func removeObjectAtIndex(index: Int){
        
        Logger.deleteHistory(dataSource[index])
        dataSource.removeAll()
        
        refreshView()
    }
    
    /**
     Function to convert NSDate object to String type object. The date format can be updated here for different types of date formats.
     :parameter: dateReceived: of type NSDate and converted into String value which is returned by the method.
     */
    func getDateTimeInString(dateReceived: NSDate) -> String {
        print("DB Fetched Date : \(dateReceived)")
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" //format style.
        let dateString = dateFormatter.stringFromDate(dateReceived)
         print("Date after formatting : \(dateString)")
        return dateString
    }

}
