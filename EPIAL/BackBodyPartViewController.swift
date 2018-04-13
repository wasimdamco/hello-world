//
//  BackBodyPartViewController.swift
//  EPIAL
//
//  Created by User on 05/06/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class BackBodyPartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .None

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
            self.navigationItem.title = "Body Parts - Back"
        // For managing the front body part screen
            NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isComingFromBackBodyPartScreen")
            createButton()
            
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    func createButton(){
        let btnName = UIButton()
        btnName.setTitle("Back", forState: .Normal)
        btnName.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 40, 30)
    
        btnName.addTarget(self, action: #selector(self.backButtonPressed(_:)), forControlEvents: .TouchUpInside)
    
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = btnName
        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    func backButtonPressed(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    @IBAction func partSelected(sender: UIButton) {
        print(sender.titleLabel?.text)
        // For managing the logger screen
        NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isNavigatingFromBothBodyPartsScreen")
        NSNotificationCenter.defaultCenter().postNotificationName("treatmentAreaValue", object: sender as UIButton)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
}
