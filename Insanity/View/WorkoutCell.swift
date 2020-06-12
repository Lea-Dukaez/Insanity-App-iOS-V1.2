//
//  WorkoutCell.swift
//  Insanity
//
//  Created by Léa on 25/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class WorkoutCell: UITableViewCell {

    @IBOutlet weak var workoutMoveLabel: UILabel!
    @IBOutlet weak var oldDataLabel: UILabel!
    @IBOutlet weak var newDataLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
