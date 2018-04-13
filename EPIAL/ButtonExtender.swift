//
//  ButtonExtender.swift
//  EPIAL
//
//  Created by User on 26/05/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import Foundation
import QuartzCore


@IBDesignable
class ButtonExtender : UIButton{

    @IBInspectable var borderWidth : CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius : CGFloat = 1.0{
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    

}
