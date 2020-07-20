//
//  WelcomeViewController.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var logInButton: UIButton!

    override func viewDidLoad() {
        print("WelcomeViewController viewDidLoad")
        
        super.viewDidLoad()
        logInButton.backgroundColor = .clear
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.label.cgColor
        
        if Auth.auth().currentUser != nil {
            DataBrain.sharedInstance.isLoggedIn = true
            
            if let userID = Auth.auth().currentUser?.uid {
                DataBrain.sharedInstance.currentUserID = userID
                DataBrain.sharedInstance.getCurrentUser()
            }
    
        } else {
            print("user not logged in")
            DataBrain.sharedInstance.isLoggedIn = false
        }
        
//        if UserDefaults.standard.object(forKey: "USER_KEY_UID") != nil {
//            currentUserID = UserDefaults.standard.object(forKey: "USER_KEY_UID") as! String
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        if DataBrain.sharedInstance.isLoggedIn {
            self.performSegue(withIdentifier: K.Segue.WelcomeVC.segueWelcomeToHome, sender: self)
        }
    }
    

    
    @IBAction func buttonSignUpPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.Segue.WelcomeVC.segueWelcomeToSignUp, sender: self)
    }
    
    @IBAction func buttonLogInPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.Segue.WelcomeVC.segueWelcomeToLogIn, sender: self)
    }
    
}
