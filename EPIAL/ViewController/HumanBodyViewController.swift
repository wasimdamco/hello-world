//
//  HumanBodyViewController.swift
//  EPIAL
//
//  Created by Juli on 16/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import Foundation
import UIKit

/**
Class: HumanBodyViewController is the controller class that loads the human body view onto screen. The controller has different views based on the height of device that needs to be loaded. The user can tap on the screen and select specific body part to view the details of how to use the device to remove pain.
*/

protocol HumanBodyViewControllerProtocol : class{
    func takeSelectedBodyPartToLoggerScreen(bodyPartName : String)
}

class HumanBodyViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    var isComingFromLoggerScreen : String = "false"
    var isComingFromBackBodyPartScreen : String = "false"
    
    weak var delegateHumanBodyViewControllerProtocol : HumanBodyViewControllerProtocol?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		self.extendedLayoutIncludesOpaqueBars = true
		self.edgesForExtendedLayout = .None
		self.navigationItem.title = "Body Parts"
	}
    
    
    // Mohit change
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // To achieve different functionality when coming from logger screen as we are reusing the body parts screen.
        
        if let value = NSUserDefaults.standardUserDefaults().valueForKey("isComingFromBackBodyPartScreen"){
            isComingFromBackBodyPartScreen = value as! String
        }
        
            if isComingFromLoggerScreen == "true" || isComingFromBackBodyPartScreen == "true"{
                self.navigationItem.title = "Body Parts - Front"
                createButton(false)
                 createButton(true)
                NSUserDefaults.standardUserDefaults().setObject("false", forKey: "isComingFromBackBodyPartScreen")
            }else{
                self.navigationItem.title = "Body Parts"
        }
        
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        //isComingFromLoggerScreen = "false"
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func partSelected(sender: AnyObject) {
        
        // Previous code
//        let bodypartsViewController = instantiateBodyDetailViewController()
//        let buttonObj = sender as! UIButton
//        let partSelectedTitle = buttonObj.titleLabel?.text
//        bodypartsViewController.selectedBodyPart = partSelectedTitle
//        self.navigationController?.pushViewController(bodypartsViewController, animated: true)

        // Mohit change
        
        let buttonObj = sender as! UIButton
        let partSelectedTitle = buttonObj.titleLabel?.text
        
        if isComingFromLoggerScreen == "true"{
            isComingFromLoggerScreen = "false"
            delegateHumanBodyViewControllerProtocol?.takeSelectedBodyPartToLoggerScreen(partSelectedTitle!)
            self.navigationController?.popViewControllerAnimated(true)
            
            // for managing logger screen 
             NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isNavigatingFromBothBodyPartsScreen")
            
        }else{
            let bodypartsViewController = instantiateBodyDetailViewController()
            bodypartsViewController.selectedBodyPart = partSelectedTitle
            self.navigationController?.pushViewController(bodypartsViewController, animated: true)
        }
        
        
    }
	
    func createButton(wantTomakeRightButton : Bool){
        let btnName = UIButton()
        if wantTomakeRightButton == true{
            btnName.setTitle("Next", forState: .Normal)
        }else{
            btnName.setTitle("Back", forState: .Normal)
        }
        
        btnName.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 50, 30)
        btnName.titleLabel!.numberOfLines = 1;
        btnName.titleLabel!.adjustsFontSizeToFitWidth = true
        btnName.titleLabel?.minimumScaleFactor = 10.0
        btnName.titleLabel?.textAlignment = .Left
        
        if wantTomakeRightButton == true{
            btnName.addTarget(self, action: #selector(self.nextButtonPressed(_:)), forControlEvents: .TouchUpInside)
        }else{
            btnName.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
        }
        
        
        //.... Set Right/Left Bar Button item
        if wantTomakeRightButton == true{
            let rightBarButton = UIBarButtonItem()
            rightBarButton.customView = btnName
            self.navigationItem.rightBarButtonItem = rightBarButton
        }else{
            let leftBarButton = UIBarButtonItem()
            leftBarButton.customView = btnName
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        
    }
    
	// Function to instantiate the BodyPartsDetailViewController and return it's instance.
	func instantiateBodyDetailViewController() -> BodyPartsDetailViewController {
		let storyboardData = UIStoryboard(name: "Main", bundle: nil)
		let bodypartsViewController = storyboardData.instantiateViewControllerWithIdentifier("BodyPartsDetailViewController") as! BodyPartsDetailViewController
		return bodypartsViewController
	}
    
        func nextButtonPressed(sender: UIButton) {
//        let story = UIStoryboard(name: "Main", bundle: nil)
//        let backBodyPartVC : BackBodyPartViewController = story.instantiateViewControllerWithIdentifier("BackBodyPartViewController") as! BackBodyPartViewController
//        self.navigationController?.pushViewController(backBodyPartVC, animated: true)
            showBackBodyParts()

    }
    
    func showBackBodyParts(){
        print(self.view.frame.height)
        if (self.view.frame.height == 455){
            let backBodypartVC = BackBodyPartViewController(nibName: "BackBodyParts", bundle: nil)
            self.navigationController?.pushViewController(backBodypartVC, animated: true)
            
            
        } else if  (self.view.frame.height == 554){
            let backBodypartVC = BackBodyPartViewController(nibName: "BackBodyParts6", bundle: nil)
            self.navigationController?.pushViewController(backBodypartVC, animated: true)
            
        }else if (self.view.frame.height == 623){
            let backBodypartVC = BackBodyPartViewController(nibName: "BackBodyParts6P", bundle: nil)
            self.navigationController?.pushViewController(backBodypartVC, animated: true)
            
        }
    }

    
    func backButtonPressed(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}


