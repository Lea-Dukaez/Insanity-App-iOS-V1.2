//
//  AddFriendCell.swift
//  Insanity
//
//  Created by Léa on 18/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var pseudolabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addPressed(_ sender: UIButton) {
    }
    
}
