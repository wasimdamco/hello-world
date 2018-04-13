//
//  Constants.swift
//  EPIAL
//
//  Created by Juli on 30/11/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

/*
* Contains simple utility classes or extensions..
*/

// MARK: General utility functions and protocols:


import Foundation
import UIKit

/**

The struct contains all the information related to device standerd controls.
Define all the constant parameters for device.
*/
struct EPDeviceInformation {
	static let nabigationBarHeight: CGFloat = 65.0
		static let tabBarHeight: CGFloat = 50.0
		static let screenHeight = UIScreen.mainScreen().bounds.height
		static let screenWidth = UIScreen.mainScreen().bounds.width
		static let remainingScreen = EPDeviceInformation.screenHeight - EPDeviceInformation.nabigationBarHeight - EPDeviceInformation.tabBarHeight
		static let tableRowHeight: CGFloat = EPDeviceInformation.remainingScreen/3.95 // Since the screen design has 4 static ros , which needs to be displayed on the screen at once
	// no scrolling should be there for these 4 items
}

/**
This struct will contain all declaration about DeviceM.
Currently it holds all pdf file names stired in order the are shown on screen.
*/
struct DeviceMDetails {
	static let pdfFileNameOptions:[String] = ["AS_M_DeviceOrientation","AS_M_How_to_use_CES","AS_M_How_to_use_TENS"]
	static let options:[String] = ["Device Orientation", "How to Use CES","How to Use MET", "Probes Treatment Strategy"]
}
/**
This struct will contain all declaration about DeviceAID.
Currently it holds all pdf file names stired in order the are shown on screen.
*/
struct DeviceAIDDetails {
	static let pdfFileNameOptions:[String] = ["AS_AID_DeviceOrientation","AS_AID_How_to_use_CES"]
	static let options:[String] = ["Device Orientation","How to Use CES"]
}

struct DeviceDetail {
	static let images: [String] = ["Device orientation", "How to Use CES", "How to Use CES", "Probes Treatment Strategy"]
}

struct CustomFonts {
	static let ProximaNova_Bold_12: UIFont? = UIFont(name: "ProximaNova-Semibold", size: 10)
}


/**
 ScreenSize is a structure to know the current device dimensions (screen width, screen height).
 */

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

/**
 DeviceType is a structure to know the current device type (IS_IPHONE_4_OR_LESS, IS_IPHONE_5, IS_IPHONE_6, IS_IPHONE_6P or IS_IPAD).
 */

struct CurrentDeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

struct ApiUrl {
   //http://demo13.damcogroup.com:8080/api/
    //http://54.208.101.67/api/
    //static let baseUrl = "http://demo13.damcogroup.com:8080/api/"
    //syncApiUrl = "http://demo13.damcogroup.com:8080/wp-json/wp/v2/save_api_data/"
    //userDataSync = "http://demo13.damcogroup.com:8080/wp-json/wp/v2/get_user_data/"
    //http://54.208.101.67/api//wp-json/wp/v2/get_user_data/
    //http://54.208.101.67/wp-json/wp/v2/get_patients_list/
    //http://54.208.101.67/wp-json/wp/v2/get_average_of_treatment_duration/
    //http://54.208.101.67/wp-json/wp/v2/get_percent_improvement_allusers/
    
    static let secondBaseURL              = "https://alpha-stimapp.com/wp-json/wp/v2/"//"http://54.174.37.142/wp-json/wp/v2/"
    static let baseUrl                    = "https://alpha-stimapp.com/api/"//"http://54.174.37.142/api/"
    static let endUrlNonce                = "get_nonce/?controller=user&method=register"
    static let endUrlEmailAndPass         = "user/register/"
    static let endUrlCompleteDetails      = "user/update_user_meta_vars/"
    static let endUrlLoginNonce           = "get_nonce/?controller=user&method=generate_auth_cookie"
    static let endUrlLoginCookie          = "user/generate_auth_cookie/"
    static let syncApiUrl                 = secondBaseURL + "save_api_data/"
    static let userDataSync               = secondBaseURL + "get_user_data/"
    static let getPatientList             = secondBaseURL + "get_patients_list/"
    static let getPractitionerCode        = secondBaseURL + "get_prac_code/"
    static let getTreatmentAllUsers       = secondBaseURL + "get_average_of_treatment_duration/"
    static let percentImprovementAllUsers = secondBaseURL + "get_percent_improvement_allusers/"
    static let checkPracCode              = secondBaseURL + "check_prac_code/"
    static let checkPatientForPrac        = secondBaseURL + "check_patient_for_prac"
}

struct syncingTimeData{

static let syncTime = "20"

}


