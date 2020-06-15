//
//  WelcomeViewController.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var currentUserID = ""
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

//    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.isNavigationBarHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.isNavigationBarHidden = false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if the user is logged in
        if UserDefaults.standard.object(forKey: "USER_KEY_UID") != nil {
        // send them to a new view controller or do whatever you want
            currentUserID = UserDefaults.standard.object(forKey: "USER_KEY_UID") as! String
            performSegue(withIdentifier: K.segueWelcomeToHome, sender: self)
        }
        
        logInButton.backgroundColor = .clear
//        logInButton.layer.cornerRadius = 5
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.label.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueWelcomeToHome {
            let homeView = segue.destination as! HomeViewController
            homeView.currentUserID = currentUserID
        }
    }
}
