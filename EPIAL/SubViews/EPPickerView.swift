//
//  EPPickerView.swift
//  EPIAL
//
//  Created by Juli on 18/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit

/**
	protocol: PickerSelectionDelegate : the protocol function to notify back the class or
	model or controller who implements and sets PickerSelectionDelegate to self about what is selected from picker.
*/
protocol PickerSelectionDelegate {

	/**
	Delegate function to send information back to the implementor controller.
	:parameter: row: Int value for selected row index
	:parameter: dataSource: String array set from which the value has been selected.
	:parameter: input: InputType enum value to know the type from pain, treatment etc.
	*/
    func didFinishSelectingRow(row: Int, dataSource: [String], input: InputType)
	func cancelButtonClicked()
}

/**
	Class: EPPickerView: The UIView model class which the controller needs to implement
	to have the picker on controller's view. The controller needs to make a instance of the EPPickerView
	model class and provide the frame as to where the picker needs to appear on the view and set the 
	delegate to self, to get the callback for selected item from the picker.
*/
class EPPickerView: UIView, UIPickerViewDelegate{

	@IBOutlet weak var picker: UIPickerView!
	@IBOutlet weak var pickerTitle: UILabel!
	var selectedValue: Int = 0
	var delegate: PickerSelectionDelegate?
	var inputSelection: InputType?
	var pickerDataSoruce:[String]?
    @IBOutlet weak var doneButton: UIButton!
	
	/**
		Class function to initialize the view from nib.
		the function loads the EPPickerView nib and sets the nib for the view.
		:returns: EPPickerView object
	*/
	class func initWithNib()-> AnyObject? {
		
		let nibChilds = NSBundle.mainBundle().loadNibNamed("EPPickerView", owner: nil, options: nil)
		var pickerView: EPPickerView?
		for nibView in nibChilds! {
			if nibView .isKindOfClass(EPPickerView){
				pickerView = nibView as? EPPickerView
			}
		}
		return pickerView
	}
	
	// UIPickerView dataSource method
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	// UIPickerView dataSource method
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerDataSoruce!.count
	}
 	// UIPickerView dataSource method
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerDataSoruce![row]
	}
	// UIPickerViewDelegate dataSource method
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedValue = row
        let rowData = pickerDataSoruce![row]
        let userDeviceModel = NSUserDefaults.standardUserDefaults().valueForKey("userDeviceModel") as? String
        if (userDeviceModel != nil) && (userDeviceModel == "Alpha-Stim AID"){
            if rowData == "Pain"{
                // Due to animation lagging we are using the button's enable property.
                doneButton.enabled = false
                doneButton.hidden = true
            }else{
                doneButton.hidden = false
                doneButton.enabled = true
            }
        }else{
                doneButton.enabled = false
                doneButton.enabled = true
        }
        
	}
	
	@IBAction func cancelButtonClicked(sender: AnyObject) {
		self.delegate?.cancelButtonClicked()
	}
	
	@IBAction func doneButtonClicked(sender: AnyObject) {
        print(selectedValue)
        print(pickerDataSoruce)
        print(inputSelection)
        self.delegate?.didFinishSelectingRow(selectedValue, dataSource: pickerDataSoruce!, input: inputSelection!)
	}
	
}
