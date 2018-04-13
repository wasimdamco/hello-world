//
//  PatientSelectionAndAdditionViewController.swift
//  EPIAL
//
//  Created by User on 23/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class PatientSelectionAndAdditionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        //managetabBarItem()
    }
    
    func managetabBarItem(){
        if  let arrayOfTabBarItems = self.tabBarController!.tabBar.items as! AnyObject as? NSArray,tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
            tabBarItem.enabled = false
        }
    }
    
    @IBAction func addPatientPressed(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let addPatientVC : AddPatientViewController = storyBoard.instantiateViewControllerWithIdentifier("AddPatientViewController") as! AddPatientViewController
        //self.navigationController?.presentViewController(addPatientVC, animated: true, completion: nil)
       self.navigationController?.pushViewController(addPatientVC, animated: true)
    }

    @IBAction func selectPatientPressed(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let selectPatientVC : SelectPatientViewController = storyBoard.instantiateViewControllerWithIdentifier("SelectPatientViewController") as! SelectPatientViewController
        
        Spinner.show("Loading...")
        PatientManager.getPaientList { (isFinished, patientCodeArray, userIDArray) in
            if isFinished == true && patientCodeArray.count > 0{
                Spinner.hide()
                selectPatientVC.tableViewDataSourcePatientCode = patientCodeArray
                selectPatientVC.tableViewDataSourceUserID = userIDArray
                 self.navigationController?.pushViewController(selectPatientVC, animated: true)
            }else{
                Spinner.hide()
                self.showAlert("No patient present")
            
            }
        }
        
        
       
    }
    
   
    
}
