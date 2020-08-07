//
//  SignInViewController.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FRHyperLabel

class SignUpViewController: UIViewController {

    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var termsOfUseLabel: FRHyperLabel!
    @IBOutlet weak var goToLogInLabel: FRHyperLabel!

    let alertEmpty = UIAlertController(title: "Error", message: "email/password can't be empty", preferredStyle: UIAlertController.Style.alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        pseudoTextField.attributedPlaceholder = NSAttributedString(string: "Pseudo",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])

        handleTermsOfUse()
        handleGoToLogIn()
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let textFieldArray = [pseudoTextField, emailTextField, passwordTextField]
        let allHaveText = textFieldArray.allSatisfy { $0!.text?.isEmpty == false }

        if !allHaveText {
            showAlert(for: alertEmpty)
        } else {
            if let pseudo = self.pseudoTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text {

                Auth.auth().createUser(withEmail: email, password: password) { (dataResult, error) in
                    if let err = error {
                        let errorMsg = "\(err.localizedDescription)"
                        let alertError = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                        self.showAlert(for: alertError)
                        return
                    }

                    if let uid = dataResult?.user.uid {
                        let randomInt = Int.random(in: 0...17)
                        let calendar: [Bool] = Array(repeating: false, count: 72)

                        DataBrain.sharedInstance.currentUserID = uid
                        DataBrain.sharedInstance.pseudoCurrentUser = pseudo
                        DataBrain.sharedInstance.avatarCurrentUser = K.avatarImages[randomInt]
                        DataBrain.sharedInstance.dataFollowedUsers = [String:String]()
                        DataBrain.sharedInstance.currentUserMaxValues = [Double]()
                        DataBrain.sharedInstance.calendarCurrentUser = calendar
                        DataBrain.sharedInstance.createUserInfo(pseudoDefault: pseudo, avatarDefault: K.avatarImages[randomInt])
                        DataBrain.sharedInstance.numberOfTestsCurrentUser = 0 
                        
//                         // keep UID for avoid login again after closing the app
//                          UserDefaults.standard.set(uid, forKey: "USER_KEY_UID")
//                          UserDefaults.standard.synchronize()
                    }
                    self.pseudoTextField.text = ""
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: K.Segue.SignUpVC.segueSignUpToHome, sender: self)
                    }
                    print("user sign up !")
                }
            }
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    // MARK: - HyperLink handler Methods
    
    func handleTermsOfUse() {
        termsOfUseLabel.numberOfLines = 0
        
        let string = "By creating an account, you agree to Insanity Progress Tracking's Terms of Use."
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        
        termsOfUseLabel.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        let handler = { (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            self.performSegue(withIdentifier: K.Segue.SignUpVC.segueSignUpGoToTerms, sender: self)
        }

        termsOfUseLabel.setLinkForSubstring("Terms of Use", withLinkHandler: handler)

    }
    
    func handleGoToLogIn() {
        goToLogInLabel.numberOfLines = 0
        
        let string = "Already a member ? Log In."
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        
        goToLogInLabel.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        let handler = { (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            
            self.performSegue(withIdentifier: K.Segue.SignUpVC.segueSignUpToLogIn, sender: self)
            
        }
        
        goToLogInLabel.setLinkForSubstring("Log In", withLinkHandler: handler)
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
    

}

