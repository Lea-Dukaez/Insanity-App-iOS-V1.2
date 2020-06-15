//
//  LoginViewController.swift
//  Insanity
//
//  Created by Léa on 11/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    var userID = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let alertEmpty = UIAlertController(title: "Error", message: "email/password can't be empty", preferredStyle: UIAlertController.Style.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        let textFieldArray = [emailTextField, passwordTextField]
        let allHaveText = textFieldArray.allSatisfy { $0!.text?.isEmpty == false }
        
        if !allHaveText {
            showAlert(for: alertEmpty)
        } else {
            if let email = self.emailTextField.text, let password = self.passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { (dataResult, error) in
                    if let err = error {
                        let errorMsg = "\(err.localizedDescription)"
                        let alertError = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                        self.showAlert(for: alertError)

                        return
                    }

                  
                    if let uid = dataResult?.user.uid {
                        self.userID = uid
                        // keep UID for avoid login again after closing the app
                        UserDefaults.standard.set(uid, forKey: "USER_KEY_UID")
                        UserDefaults.standard.synchronize()
                    }
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: K.segueLoginToHome, sender: self)
                    print("user logged in !")
                }
            }
        }
    }
    
    func showAlert(for alert: UIAlertController) {
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueLoginToHome {
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! FeedViewController
            destinationVC.currentUserID = userID
            
            let homeView = tabCtrl.viewControllers![3] as! HomeViewController
            homeView.currentUserID = userID
            
            let progressView = tabCtrl.viewControllers![1] as! ProgressViewController
            progressView.userName = "Malfouf le moche"
            progressView.avatarImg = "avatar7"
            progressView.uid = userID
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)

//        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    

}
