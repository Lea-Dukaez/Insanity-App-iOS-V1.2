//
//  NewPasswordViewController.swift
//  Insanity
//
//  Created by Léa on 14/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewPasswordViewController: UIViewController {

    var userEmail = ""
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func sendPressed(_ sender: UIButton) {
        
        if emailTextField.text?.isEmpty == false {
            if let email = self.emailTextField.text {
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if let err = error {
                        let errorMsg = "\(err.localizedDescription)"
                        let alertError = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertController.Style.alert)
                        self.showAlert(for: alertError)

                        return
                    }
                    self.userEmail = email
                    self.performSegue(withIdentifier: K.segueToReset, sender: self)
                    self.emailTextField.text = ""
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueToReset {
            let resetVC = segue.destination as! ResetViewController
            resetVC.userEmail = userEmail
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
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)

    }


}
