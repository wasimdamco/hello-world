//
//  BodyPartsDetailView.swift
//  EPIAL
//
//  Created by User on 07/01/16.
//  Copyright © 2016 Akhil. All rights reserved.
//

import Foundation
import UIKit

/**
Class: BodyPartsDetailView is the view class that load the view that contains 2 components. The image view and the textview that contains the description of the image. The configure view method is used to set up textview and image view with related data value.
*/
class BodyPartsDetailView : UIView  {
    
    @IBOutlet weak var bodyPartImageView: UIImageView!
    @IBOutlet weak var bodyDetailTextView: UITextView!
    
     var bodyPartsDetailView:BodyPartsDetailView {
        get{
            let views = NSBundle.mainBundle().loadNibNamed("BodyPartsDetailView", owner: self, options: nil)
            let view = views![0] as! BodyPartsDetailView
            return view
        }
    }
	// Function to add data values from "details" dictionary onto the view.
    func configureView(details:[String:String]){
		
        let image = UIImage(named: details["imageName"]!.capitalizedString)
        bodyPartImageView.image = image
        bodyDetailTextView.text = details["imageDescription"]
        bodyDetailTextView.scrollEnabled = true
        bodyDetailTextView.editable = false
        bodyDetailTextView.font = UIFont(name: "ProximaNova-Regular", size: 16.0)
    }
    
    
}
