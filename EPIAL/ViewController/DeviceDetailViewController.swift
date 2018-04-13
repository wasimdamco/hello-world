//
//  DeviceDetailViewController.swift
//  EPIAL
//
//  Created by Juli on 15/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import Foundation
import UIKit

/**
Enum for type of devices application support
*/
enum DeviceType {
	case DeviceM
	case DeviceAID
}


enum Heights:CGFloat {
	case Inches_3_5 = 480
	case Inches_4 = 568
	case Inches_4_7 = 667
	case Inches_5_5 = 736
}

class DeviceDetailViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
	
	var dataSource: [String] = [String]()
	var documentInteractionController:UIDocumentInteractionController?
	var selectedDevice: DeviceType?

    override func viewDidLoad() {
        super.viewDidLoad()
		self.automaticallyAdjustsScrollViewInsets = false
        // Do view setup here.
    }
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	
		let cellIdentifier:String = "CustomCell"
	
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
		if (cell == nil)
			{
				cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
			}
		cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		cell?.textLabel?.text = dataSource[indexPath.row]
		cell?.imageView?.image = UIImage(named: DeviceDetail.images[indexPath.row])
		let imageView: UIImageView = UIImageView(frame: CGRectMake(0, 0, (cell?.frame.size.width)!, (cell?.frame.size.height)!))
		imageView.image = UIImage(named: "Rowstrip")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch)
		cell?.backgroundView = imageView
		cell?.selectionStyle = UITableViewCellSelectionStyle.None
		return cell!
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return EPDeviceInformation.tableRowHeight
	}
	
	/**
	
	Tableview didSelect delegate method. Here we
	*/
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
		switch selectedDevice! {
		
		case DeviceType.DeviceM:
 				deviceMOptionSelectionAction(indexPath.row, selectedCell: cell!)
			break
		
		case DeviceType.DeviceAID:
				let pdfViewController = storyboard!.instantiateViewControllerWithIdentifier("PDFViewController") as! PDFViewController
				pdfViewController.titleText = cell?.textLabel?.text
				pdfViewController.pdfFileName = DeviceAIDDetails.pdfFileNameOptions[indexPath.row]
				self.navigationController?.pushViewController(pdfViewController, animated: true)
			break
		}

	}

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
	}
	
	/**
	Function will confirm action on DeviceM selected option.
	If 0 to 2nd row is selected then PDF view needs to be opened else
	Body part that is Probes Treatment Strategy controller will be opened.
	:parameter:: selectedRow: Int to identify which row is selected.
	*/
	func deviceMOptionSelectionAction(selectedRow: Int, selectedCell: UITableViewCell) {
	
		if selectedRow <= 2 {
			let pdfViewController = storyboard!.instantiateViewControllerWithIdentifier("PDFViewController") as! PDFViewController
			pdfViewController.pdfFileName = DeviceMDetails.pdfFileNameOptions[selectedRow]
			pdfViewController.titleText = selectedCell.textLabel?.text
			self.navigationController?.pushViewController(pdfViewController, animated: true)
		}
		else{
		self.loadnib()
		}

	}
	
	// Function to load the xib of BodyParts based on the specific device height, in which the page is being opened.
	func loadnib (){
		if (self.view.frame.height == 568){
			let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts", bundle: nil)
			self.navigationController?.pushViewController(humanBodyViewController, animated: true)

		} else if  (self.view.frame.height == 667){
			let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts6", bundle: nil)
			self.navigationController?.pushViewController(humanBodyViewController, animated: true)

		}else if (self.view.frame.height == 736){
			let humanBodyViewController = HumanBodyViewController(nibName: "BodyParts6P", bundle: nil)
			self.navigationController?.pushViewController(humanBodyViewController, animated: true)

		}
	}
	
}
