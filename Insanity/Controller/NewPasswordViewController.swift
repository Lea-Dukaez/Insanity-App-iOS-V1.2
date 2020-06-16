//
//  NewPasswordViewController.swift
//  Insanity
//
//  Created by Léa on 14/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class NewPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func sendPressed(_ sender: UIButton) {
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)

    }


}
