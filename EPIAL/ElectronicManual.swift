//
//  ElectronicManual.swift
//  EPIAL
//
//  Created by Akhil on 26/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import UIKit

/**
 Class: ElectronicManual is the controller class that displays the options to user for selecting the type of device they use. Once the user selects a specific device data related to that device is loaded. User can go through the manuals and understand device screen orientations and how  to use the device for treatment of specific area. User also gets the option to see how to use the probes along with the device by selecting specific body part.
 */

class ElectronicManual: UIViewController {
    
    
    var isSyncingDone : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Start Syncing
        self.startSyncing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // Button action on click of "Device M" image
    @IBAction func deviceMSelected(sender: AnyObject) {
        let deviceDetail = storyboard?.instantiateViewControllerWithIdentifier("DeviceDetailViewController") as! DeviceDetailViewController
        deviceDetail.title = "Alpha-Stim M"
        deviceDetail.dataSource = DeviceMDetails.options
        deviceDetail.selectedDevice = DeviceType.DeviceM
        self.navigationController?.pushViewController(deviceDetail, animated: true)
        
    }
    // Button action on click of "Device AID" image
    @IBAction func deviceAIDSelected(sender: AnyObject) {
        
        let deviceDetail = storyboard?.instantiateViewControllerWithIdentifier("DeviceDetailViewController") as! DeviceDetailViewController
        deviceDetail.title = "Alpha-Stim AID"
        deviceDetail.dataSource = DeviceAIDDetails.options
        deviceDetail.selectedDevice = DeviceType.DeviceAID
        self.navigationController?.pushViewController(deviceDetail, animated: true)
        
    }
    
    @IBAction func logoutPressed(sender: UIButton) {
        
     /**
        let alert = UIAlertController(title: "", message: "Data will get lost without syncing. Do you want to logout?", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            Logger.deleteAlldataFromDB()
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "practitionerCode")
            let storyLogin = UIStoryboard(name: "Login", bundle: nil)
            let loginVcNavigationController : EPNavigationController = storyLogin.instantiateViewControllerWithIdentifier("EPNavigationController") as! EPNavigationController
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookie")
            self.view.window?.rootViewController = loginVcNavigationController
            
            
         //   SignUpViewController
          //  let storyLogin = UIStoryboard(name: "Login", bundle: nil)
//            let loginVcNavigationController : LoginViewController = storyLogin.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookie")
//            self.view.window?.rootViewController = loginVcNavigationController
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
 **/
        
        self.logoutPressed()
        
    }
    
    // Syncing Method
    func startSyncing(){
        
        let stringEightPM = syncingTimeData.syncTime
        
        if #available(iOS 10.0, *) {
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, repeats: true) { (timer) in
                let calendar = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
                //print(calendar)
                if String(calendar) == stringEightPM{
    
                    if self.isSyncingDone == false{
                        SyncManager.syncData(false)
                        self.isSyncingDone = true
                    }
                
                }else{
                    self.isSyncingDone = false
                }
            }
        } else {
            
            _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:  #selector(ElectronicManual.timerMethod), userInfo: nil, repeats: true)
        }
        
    }
    
    
    
    func timerMethod(){
        let stringEightPM = syncingTimeData.syncTime
        let calendar = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        //print(calendar)
        if String(calendar) == stringEightPM{
            SyncManager.syncData(false)
            if self.isSyncingDone == false{
                SyncManager.syncData(false)
                self.isSyncingDone = true
            }
        }else{
            self.isSyncingDone = false
        }
    }
    
    
}

