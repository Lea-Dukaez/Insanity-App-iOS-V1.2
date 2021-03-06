//
//  TestViewController.swift
//  Insanity
//
//  Created by Léa on 24/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class TestViewController: UIViewController {
    
    var workoutDate = Date()
    var listWorkoutTest = [Double]()
    var textFieldArray = [UITextField]()
    var workoutLabelsArray = [UILabel]()
    
    let alert = UIAlertController(title: "Incomplete", message: "Please fill all the exercises", preferredStyle: UIAlertController.Style.alert)
    let forbiddenNumber = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09"]

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var validateButton: UIButton!
    
    
    @IBOutlet weak var SwitchKicksLabel: UILabel!
    @IBOutlet weak var PowerJacksLabel: UILabel!
    @IBOutlet weak var PowerKneesLabel: UILabel!
    @IBOutlet weak var PowerJumpsLabel: UILabel!
    @IBOutlet weak var GlobalJumpSquatLabel: UILabel!
    @IBOutlet weak var SuicideJumpLabel: UILabel!
    @IBOutlet weak var PushUpJacksLabel: UILabel!
    @IBOutlet weak var LowPlankObliqueLabel: UILabel!
    
    @IBOutlet weak var SKTextField: UITextField!
    @IBOutlet weak var PJKTextField: UITextField!
    @IBOutlet weak var PKTextField: UITextField!
    @IBOutlet weak var PJTextField: UITextField!
    @IBOutlet weak var JSQTextField: UITextField!
    @IBOutlet weak var SJTextField: UITextField!
    @IBOutlet weak var PUJKTextField: UITextField!
    @IBOutlet weak var PMCTextField: UITextField!
    
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
    
        textFieldArray = [SKTextField, PJKTextField, PKTextField, PJTextField, JSQTextField, SJTextField, PUJKTextField, PMCTextField]
        workoutLabelsArray = [SwitchKicksLabel, PowerJacksLabel, PowerKneesLabel, PowerJumpsLabel,
                              GlobalJumpSquatLabel, SuicideJumpLabel, PushUpJacksLabel, LowPlankObliqueLabel]

        for textField in textFieldArray {
            textField.delegate = self
            textField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
            textField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        }
        
        for (index,workoutLabel) in workoutLabelsArray.enumerated() {
            workoutLabel.text = DataBrain.sharedInstance.currentUserMaxValues.isEmpty ? "" : "Your best score: \(Int(DataBrain.sharedInstance.currentUserMaxValues[index]))"
        }
    }
    
    @objc func updateDateField(sender: UIDatePicker) {
        workoutDate = sender.date
    }
    
    @IBAction func validatePressed(_ sender: UIButton) {
        
        let allHaveText = textFieldArray.allSatisfy { $0.text?.isEmpty == false }
        if allHaveText {
            for textField in textFieldArray {
                listWorkoutTest.append(Double(textField.text!)!)
            }
            
            // Add a new document in Firestore for currentUser
            DataBrain.sharedInstance.saveNewWorkout(testResults: self.listWorkoutTest, workoutDate: self.workoutDate)
            DataBrain.sharedInstance.majMax(testResults: self.listWorkoutTest) 
            
            self.listWorkoutTest = [Double]()
            
            // dismiss view
            self.navigationController?.popViewController(animated: true)
   
        } else {
            showAlert()
        }
    }
    
    func showAlert() {
        self.present(alert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            self.alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func doneButtonClicked(_ sender: UITextField) {
        if sender == PMCTextField {
            sender.resignFirstResponder()
        } else {
            if let senderIndex = textFieldArray.firstIndex(where: {$0 == sender}) {
                textFieldArray[senderIndex+1].becomeFirstResponder()
            }
        }
    }
    
    
}

// MARK: - UITextFieldDelegate

extension TestViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        //Prevent "0" characters to be followed by other number
        if forbiddenNumber.contains(text) {
            return false
        }
        //Limit the character count to 3.
        if ((textField.text!) + string).count > 3 {
            return false
        }
        //Only allow numbers. No Copy-Paste text values.
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
        let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
            return false
        }
        return true
    }
}
