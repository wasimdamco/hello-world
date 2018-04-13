//
//  SelectPatientViewController.swift
//  EPIAL
//
//  Created by User on 24/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class SelectPatientViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tableViewDataSourcePatientCode = [String]()
    var tableViewDataSourceUserID = [String]()
    var patientCode : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hiding tableView Extra cell
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.title = "Patient List"
        
        tableView.reloadData()
    }
    
    
    func addSelectedPatientDataToDB(id : Int){
    
        NSUserDefaults.standardUserDefaults().setObject(id, forKey: "user_id")
        NSUserDefaults.standardUserDefaults().setObject(patientCode, forKey: "patient_code")
        Spinner.show("Loading...")
        SyncManager.getUserDataIfPresent({ (isCompleted) in
            if isCompleted == true{
                Spinner.hide()
               self.pushPopController()
            }
        })
    }
   
    
}

extension SelectPatientViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSourcePatientCode.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let patientCell = tableView.dequeueReusableCellWithIdentifier("SelectPatientCell")
        patientCell?.textLabel?.text = "Patient Code: " + tableViewDataSourcePatientCode[indexPath.row]
        return patientCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let userId = Int(tableViewDataSourceUserID[indexPath.row])
        patientCode = tableViewDataSourcePatientCode[indexPath.row]
        print(userId)
        addSelectedPatientDataToDB(userId!)
        
    }

}
