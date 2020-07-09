//
//  AddFriendCell.swift
//  Insanity
//
//  Created by Léa on 18/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class AddFriendCell: UITableViewCell {

    var userID = ""
    var userStatus = ""
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var pseudolabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var user: ((String?) -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addButton.titleLabel?.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addPressed(_ sender: UIButton) {
        if let addPressed = self.user {
            addPressed(userID)
         }
    }
}
