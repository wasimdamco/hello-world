//
//  EPDatePickerView.swift
//  EPIAL
//
//  Created by Juli on 18/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
/**
protocol: DatePickerSelectionDelegate : the protocol function to notify back the class or
model or controller who implements and sets PickerSelectionDelegate to self about what is selected from picker.
*/
protocol DatePickerSelectionDelegate {
	
	/**
	Delegate function to send information back to the implementor controller.
	:parameter: selectedDate: selected date in string 
	:parameter: input: InputType enum value to know the type from pain, treatment etc.
	*/
	func didFinishSelectingDate(selectedDate: String, input: InputType)
	func cancelButtonClicked()
}

/**
Class: EPDatePickerView: The UIView model class which the controller needs to implement
to have the picker on controller's view. The controller needs to make a instance of the EPDatePickerView
model class and provide the frame as to where the picker needs to appear on the view and set the
delegate to self, to get the callback for selected date from the picker.
*/

class EPDatePickerView: UIView {

	@IBOutlet weak var datePicker: UIDatePicker!
	var delegate: DatePickerSelectionDelegate?
	var inputSelection: InputType?
	
	@IBOutlet weak var pickerTitle: UILabel!
	
	/**
		Class function to initialize the view from nib.
		the function loads the EPDatePickerView nib and sets the nib for the view.
		:returns: EPDatePickerView object
	*/
	class func initWithNib()-> AnyObject? {
		
		let nibChilds = NSBundle.mainBundle().loadNibNamed("EPDatePickerView", owner: nil, options: nil)
		var datePickerView: EPDatePickerView?
		for nibView in nibChilds! {
			if nibView .isKindOfClass(EPDatePickerView){
				datePickerView = nibView as? EPDatePickerView
			}
		}
		datePickerView?.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
		return datePickerView
	}


	/**
	Button action function to respond back with selected
	date value from the datePicker.
	*/
	@IBAction func selectedDate(sender: AnyObject) {
		
	}
	@IBAction func doneButtonClicked(sender: AnyObject) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
		let strDate = dateFormatter.stringFromDate(datePicker.date)
		self.delegate?.didFinishSelectingDate(strDate, input: inputSelection!)
	}
	@IBAction func cancelButtonClicked(sender: AnyObject) {
		self.delegate?.cancelButtonClicked()
	}
}
