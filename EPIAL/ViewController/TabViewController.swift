//
//  TabViewController.swift
//  EPIAL
//
//  Created by Mohit on 17/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit

/**
Class: TabViewController is the controller class that loads the tab view onto lower portion of the screen. The class also sets the font type and font size of the text that gets displayed onto the tabs, along with it's color.
*/
class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
		for item in self.tabBar.items!{
			item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
			item.selectedImage = item.selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
		}
		self.tabBar.backgroundImage = UIImage(named: "Bottombar")
		 UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName : CustomFonts.ProximaNova_Bold_12!], forState:.Normal)
		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName : CustomFonts.ProximaNova_Bold_12!], forState:.Selected)
		//UITabBar.appearance().selectionIndicatorImage = UIImage(named: "Bottombar_strip_selected1x")!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch)
        self.navigationController?.navigationBarHidden = true
    }

	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
 	override func preferredStatusBarStyle() -> UIStatusBarStyle {
	
		return UIStatusBarStyle.LightContent;
	}

}





