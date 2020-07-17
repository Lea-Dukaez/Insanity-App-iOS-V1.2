//
//  AccountViewController.swift
//  Insanity
//
//  Created by Léa on 12/05/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        self.pseudoTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("AccountViewController viewDidLoad")

        pseudoTextField.attributedPlaceholder = NSAttributedString(string: "Change your pseudonyme", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        currentUserImage.image = UIImage(named: DataBrain.sharedInstance.avatarCurrentUser)
        currentUserLabel.text = DataBrain.sharedInstance.pseudoCurrentUser

        pseudoTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func infoNavButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.Segue.segueSettingsToInfos, sender: self)
    }
    
    
    @IBAction func validatePressed(_ sender: UIButton) {
        saveProfile()
    }
    
    func saveProfile() {
        if pseudoTextField.text?.isEmpty == false {
            DataBrain.sharedInstance.pseudoCurrentUser = pseudoTextField.text!
        }
        DataBrain.sharedInstance.changePseudoAndImage()
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: - UICollectionViewDataSource

extension AccountViewController:  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return K.avatarImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.reuseAvatarIdentifier, for: indexPath) as! AvatarCollectionViewCell
        
        cell.avatarCellImage.image = UIImage(named: K.avatarImages[indexPath.item])
        
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension AccountViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DataBrain.sharedInstance.avatarCurrentUser = K.avatarImages[indexPath.item]
    }

}

// MARK: - UITextFieldDelegate

extension AccountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Limit the character count to 3.
        if ((textField.text!) + string).count > 25 {
            return false
        }
        return true
    }
}
