//
//  AnalysisSectionViewCell.swift
//  EPIAL
//
//  Created by User on 22/11/17.
//  Copyright © 2017 Akhil. All rights reserved.
//

import UIKit

class AnalysisSectionViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
       // configureView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureView(){
        titleLabel.layer.borderWidth = 1.0
        titleLabel.layer.borderColor = UIColor.whiteColor().CGColor
    }

}
