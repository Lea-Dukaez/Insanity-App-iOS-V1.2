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
    
    var currentUserID = ""
        
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("WelcomeViewController viewDidLoad called")

        
        // Check if the user is logged in
        if UserDefaults.standard.object(forKey: "USER_KEY_UID") != nil {
            currentUserID = UserDefaults.standard.object(forKey: "USER_KEY_UID") as! String
            
            self.performSegue(withIdentifier: K.segueWelcomeToHome, sender: self)
        }
        
        logInButton.backgroundColor = .clear
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.label.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueWelcomeToHome {
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! FeedViewController
            destinationVC.currentUserID = currentUserID
            
            let progressView = tabCtrl.viewControllers![1] as! ProgressViewController
            progressView.uid = currentUserID
            
            let podiumView = tabCtrl.viewControllers![2] as! PodiumViewController
            podiumView.currentUserID = currentUserID
            
            let homeView = tabCtrl.viewControllers![3] as! ProfileViewController
            homeView.currentUserID = currentUserID
        }
    }
        
}
