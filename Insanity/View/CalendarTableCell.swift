//
//  CalendarTableCell.swift
//  Insanity
//
//  Created by Léa Dukaez on 24/08/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class CalendarTableCell: UITableViewCell {

    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
