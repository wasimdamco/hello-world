//
//  EPNavigationController.swift
//  EPIAL
//
//  Created by Juli on 30/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit
import Foundation

/**
	Class: EPNavigationController the subclass of UINavigationController. The class is designed to
	customize the navigation controller so to give custom effects. A function awakeFromNib is overridden
	so that all the custom effects gets applied on as the navigation is loaded.
	The customization of navigationController include title color change, fon change , background
	image change etc.
*/
class EPNavigationController: UINavigationController {

	override func awakeFromNib() {
		let titleDict: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
		self.navigationBar.titleTextAttributes = titleDict
		self.navigationBar.tintColor = UIColor.whiteColor()
		//UINavigationBar.appearance().setBackgroundImage(UIImage(named: "Bottombar_strip-1")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: .Default)
		
	}

}
