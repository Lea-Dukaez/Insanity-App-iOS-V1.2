//
//  ResetViewController.swift
//  Insanity
//
//  Created by Léa on 14/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class ResetViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }

}
