//
//  SignInViewController.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    let db = Firestore.firestore()
    
    var pseudoCurrentUser = ""
    var avatar = ""
    var userID = ""


    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let alertEmpty = UIAlertController(title: "Error", message: "email/password can't be empty", preferredStyle: UIAlertController.Style.alert)

    override func viewDidLoad() {
        super.viewDidLoad()
        pseudoTextField.attributedPlaceholder = NSAttributedString(string: "Pseudo",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
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
                        self.userID = uid
                        // keep UID for avoid login again after closing the app
                          UserDefaults.standard.set(uid, forKey: "USER_KEY_UID")
                          UserDefaults.standard.synchronize()
                    }
                    let randomInt = Int.random(in: 0...17)
                    self.pseudoCurrentUser = pseudo
                    self.avatar = K.avatarImages[randomInt]
                    self.createUserInfo(pseudoDefault: self.pseudoCurrentUser, avatarDefault: self.avatar)
                    self.pseudoTextField.text = ""
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.performSegue(withIdentifier: K.segueSignUpToHome, sender: self)
                    print("user sign up !")
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

    func createUserInfo(pseudoDefault: String, avatarDefault: String) {
        // Add a new document in Firestore for new user
        self.db.collection(K.FStore.collectionUsersName).document(self.userID).setData([
            K.FStore.maxField: [Double](),
            K.FStore.friendsField: [String](),
            K.FStore.pseudoField: pseudoDefault,
            K.FStore.avatarField: avatarDefault
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueSignUpToHome {
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            
            let progressView = tabCtrl.viewControllers![0] as! ProgressViewController
            progressView.uid = userID

            let podiumView = tabCtrl.viewControllers![1] as! PodiumViewController
            podiumView.currentUserID = userID
            
            let profileView = tabCtrl.viewControllers![2] as! ProfileViewController
            profileView.currentUserID = userID
            profileView.pseudoCurrentUser = pseudoCurrentUser
            profileView.avatarCurrentUser = avatar
        }
    }
    
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
}

