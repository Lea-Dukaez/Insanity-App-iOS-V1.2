//
//  AvatarCollectionViewCell.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class AvatarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarCellImage: UIImageView!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                super.isSelected = true
                self.contentView.backgroundColor = UIColor(named: K.BrandColor.orangeBrancColor)
            }
            else
            {
                super.isSelected = false
                self.contentView.backgroundColor = .clear
            }
        }
    }
    
    
}
