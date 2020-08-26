//
//  TestResultCell.swift
//  Insanity
//
//  Created by Léa Dukaez on 26/08/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class TestResultCell: UITableViewCell {

    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var workoutScore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
