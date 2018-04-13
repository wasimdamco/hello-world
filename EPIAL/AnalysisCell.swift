//
//  AnalysisCell.swift
//  EPIAL
//
//  Created by User on 22/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class AnalysisCell: UITableViewCell {

    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryTitleValue: UILabel!
    @IBOutlet weak var allUsersTitle: UILabel!
    @IBOutlet weak var allUsersValue: UILabel!
    @IBOutlet weak var treatmentDurationTitle: UILabel!
    @IBOutlet weak var mostEffectFrequencyValue: UILabel!
    @IBOutlet weak var mostEffectiveCurrentValue: UILabel!
    @IBOutlet weak var treatmentDurationValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
