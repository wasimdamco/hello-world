//
//  EPTabBar.swift
//  EPIAL
//
//  Created by Juli on 30/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//


import UIKit
import Foundation

class EPTabBar: UITabBar {
	
	override func awakeFromNib() {
		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
		UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
		UITabBarItem.appearance().image?.imageWithRenderingMode(.AlwaysOriginal)
		
	}

}
