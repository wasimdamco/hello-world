//
//  EPHistoryTableViewCell.swift
//  EPIAL
//
//  Created by Akhil on 28/12/15.
//  Copyright © 2015 Akhil. All rights reserved.
//

import Foundation
import UIKit

/**
Class: EPHistoryTableViewCell: This is a custom UIView subclass and is used to load the data on logger screen UITableView
*/

class EPHistoryTableViewCell: UITableViewCell  {
	
    @IBOutlet weak var treatmentAreaTitleLabel: UILabel!
    @IBOutlet weak var treatmentAreaValue: UILabel!
    @IBOutlet weak var currentValue: UILabel!
    @IBOutlet weak var frequencyValue: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
	@IBOutlet weak var preTreatmentLevelValue: UILabel!
    @IBOutlet weak var postTreatmentLevelValue: UILabel!
	@IBOutlet weak var treatmentDurationValue: UILabel!
	@IBOutlet weak var dateTimeValue: UILabel!
	@IBOutlet weak var typeValue: UILabel!
	@IBOutlet weak var painLevelLabel: UILabel!
}
