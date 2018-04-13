//
//  PDFViewController.swift
//  EPIAL
//
//  Created by Juli on 30/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
import Foundation

/**
Class: PDFViewController is the controller class that loads the pdf on webview. The function openPdf() is used to load the pdf file from project resources folder. The class has 2 local variables that can be set by class in which instance of this class is created.
*/

class PDFViewController: UIViewController {
	@IBOutlet weak var pdfWebView: UIWebView!
	var pdfFileName:String?
	var titleText: String?
	
	override func viewDidLoad() {
		self.navigationItem.title = titleText
		self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
		pdfWebView.opaque = false
		openPdf(pdfFileName)
	}
	
	/// The function openPdf() is used to load the pdf file from project resources folder.
	/// param: fileName of type String, is the name of the pdf file that needs to be loaded onto webview.
	func openPdf(fileName: String?){
		 let pdfLoc = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource(fileName, ofType:"pdf")!) //replace PDF_file with your pdf file name
			let request = NSURLRequest(URL: pdfLoc);
			pdfWebView.loadRequest(request);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// The preferred status bar style for the view controller.
	//	A UIStatusBarStyle key indicating your preferred status bar style for the view controller.
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
}
