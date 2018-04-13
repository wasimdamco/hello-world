//
//  BodyPartsDetailViewController.swift
//  EPIAL
//
//  Created by Juli on 16/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//http://stackoverflow.com/questions/29074454/how-to-create-a-scroll-view-with-a-page-control-using-swift

import Foundation
import UIKit

/**
Class: BodyPartsDetailViewController is the controller class that loads the human body part details view onto screen. The view has 2 components the image view holding image of how to use the device and the description text that describes how the device can be used to remove pain. The class also uses a 3rd party library PunchScrollView. This class has data source and delgate methods that need to be set and it efficiently loads the data onto scrollview. PunchScrollView has properties configurable similar to that of UITableView and hence maked loading and unloading of data on screen efficient.
*/
class BodyPartsDetailViewController: UIViewController, UIScrollViewDelegate, PunchScrollViewDelegate, PunchScrollViewDataSource {
	
	@IBOutlet weak var pageControl: UIPageControl!
	@IBOutlet weak var scrollviewBase: PunchScrollView!
	var selectedBodyPart: String?
	private var sourceData: NSDictionary?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.edgesForExtendedLayout = .None
		self.navigationItem.title = selectedBodyPart?.capitalizedString
		self.navigationController!.navigationBar.topItem!.title = "Back"
		loadSourceData()
		configurePageControl()
		scrollviewBase.delegate = self
		scrollviewBase.dataSource = self
		
		//		scrollviewBase.showsHorizontalScrollIndicator = true
	}
	
	override func viewWillDisappear(animated: Bool) {
        
		let controller = self.navigationController?.viewControllers.last
		controller?.navigationItem.title = "Body Parts"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// Function to fetch data based on key read the values and return a tuple of type (String, String). These values are then loaded onto the screen via function "viewForPageAtIndexPath"
	func fetchData(selectedData: AnyObject)-> (text:String, imageName:String)? {
		if let data = selectedData as? NSDictionary {
			return (data["text"] as! String, data["picture"] as! String)
		}
		return nil
	}
	
	// Function to configure the UIPageControl onto screen. You can determine the size of UIPageControl by using it's method sizeForNumberOfPages(pageCount). The size of UIPageControl can then be reduced to accomodate all dots onto the screen.
	func configurePageControl() {
		var selectedData: NSArray!
		if let dict = self.sourceData {
			selectedData  = (dict[selectedBodyPart!.lowercaseString] as? NSArray)!
		}
		self.pageControl.numberOfPages = selectedData.count
		self.pageControl.currentPage = 0
		let pageControlSize = self.pageControl.sizeForNumberOfPages(selectedData.count)
		if pageControlSize.width >= self.view.bounds.size.width {
			self.pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7)
		}
	}
	
	//MARK: PunchScrollView Delegate Methods
	func numberOfSectionsInPunchScrollView(scrollView: PunchScrollView!) -> Int {
		return 1
	}
	
	func punchscrollView(scrollView: PunchScrollView!, numberOfPagesInSection section: Int) -> Int {
		var selectedData: NSArray!
		if let dict = self.sourceData {
			selectedData  = (dict[selectedBodyPart!.lowercaseString] as? NSArray)!
		}
		return selectedData.count
	}
	
	func punchScrollView(scrollView: PunchScrollView!, viewForPageAtIndexPath indexPath: NSIndexPath!) -> UIView! {
		
		var bodyPartDetailView = scrollView.dequeueRecycledPage() as? BodyPartsDetailView
		
		if bodyPartDetailView == nil{
			bodyPartDetailView = BodyPartsDetailView().bodyPartsDetailView
			bodyPartDetailView?.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
		}
		if let selectedData: NSArray = sourceData?.objectForKey(selectedBodyPart!.lowercaseString) as? NSArray {
			let data = fetchData(selectedData[indexPath.row])
			let bodyDetails = ["imageName" : data!.1 , "imageDescription" : data!.0]
			bodyPartDetailView!.configureView(bodyDetails)
		}
		return bodyPartDetailView
		
	}
	
	// Function to load plist file from resource folder and store the data in the form of NSDictionary.
	func loadSourceData() {
		var sourceData: NSDictionary?
		if let path = NSBundle.mainBundle().pathForResource("BodyParts", ofType: "plist") {
			sourceData = NSDictionary(contentsOfFile: path)
		}
		self.sourceData = sourceData
	}
	
	// UIScrollView delegate function, here update page control when the pages are scrolled to display current page
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
		pageControl.currentPage = Int(pageNumber)
	}
	
	
	
}
