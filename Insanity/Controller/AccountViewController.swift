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

    let db = Firestore.firestore()
    var avatarImage = ""
    var pseudo = ""
    var userID = ""

    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pseudoTextField.attributedPlaceholder = NSAttributedString(string: "Change your pseudonyme", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        currentUserImage.image = UIImage(named: avatarImage)
        currentUserLabel.text = pseudo

        pseudoTextField.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }

    @IBAction func closePressed(_ sender: UIButton) {
        saveProfile()
    }
    
    @IBAction func validatePressed(_ sender: UIButton) {
        saveProfile()
    }
    
    func saveProfile() {
        if pseudoTextField.text?.isEmpty == false {
            pseudo = pseudoTextField.text!
        }
        changePseudoAndImage()
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: K.segueAccountToProfile, sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == K.segueAccountToProfile {
//            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
//            let homeView = tabCtrl.viewControllers![3] as! HomeViewController
//            homeView.pseudoCurrentUser = pseudo
//            homeView.avatarCurrentUser = avatarImage
//            homeView.currentUserID = userID
//        }
//    }
    
    func changePseudoAndImage() {
        let imageURL = Bundle.main.url(forResource: self.avatarImage, withExtension: "png")
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = self.pseudo
        changeRequest?.photoURL = imageURL
        changeRequest?.commitChanges { (error) in
            if let err = error {
                print(err)
            }
        }
        
        self.db.collection(K.FStore.collectionUsersName).document(self.userID).updateData([
            K.FStore.pseudoField: self.pseudo,
            K.FStore.avatarField: self.avatarImage,
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            } else {
                print("Document added!")
                self.pseudoTextField.text = ""
                self.avatarImage = ""
                self.pseudo = ""
            }
        }
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
        avatarImage = K.avatarImages[indexPath.item]
        
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
