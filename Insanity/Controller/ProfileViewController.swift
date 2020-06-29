//
//  ViewController.swift
//  Insanity
//
//  Created by Léa on 23/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController {
    
    var pseudoCurrentUser : String = ""
    var avatarCurrentUser : String = ""
    var currentUserID = ""
    
    var friendPseudo = ""
    var friendAvatar = ""
    var friendID = ""
    
    var dataUsers: [User] = []
    let db = Firestore.firestore()
    
    @IBOutlet weak var competitorsLabel: UILabel!
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);

        addFriendsButton.backgroundColor = .clear
        addFriendsButton.layer.borderWidth = 1
        addFriendsButton.layer.borderColor = UIColor.label.cgColor
        logOutButton.backgroundColor = .clear
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.borderColor = UIColor.label.cgColor
        
        getCurrentUser()
        
        self.competitorsLabel.text = "No Friends to compete with yet !"
        self.competitorsLabel.textAlignment = .center
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: K.userCell.userCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.userCellIdentifier)
        self.tableView.tableFooterView = UIView()
        
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUserLabel.text = self.pseudoCurrentUser
        self.currentUserImage.image = UIImage(named: self.avatarCurrentUser)
    }
    
    func getCurrentUser() {
        self.db.collection(K.FStore.collectionUsersName).document(currentUserID)
            .getDocument { (document, error) in
            if let doc = document {
                if let data = doc.data() {
                    if let pseudo = data[K.FStore.pseudoField] as? String, let avatar = data[K.FStore.avatarField] as? String {
                        self.pseudoCurrentUser = pseudo
                        self.avatarCurrentUser = avatar
                        DispatchQueue.main.async {
                            self.currentUserLabel.text = self.pseudoCurrentUser
                            self.currentUserImage.image = UIImage(named: self.avatarCurrentUser)
                        }
                    }
                }
            }
        }
    }
    
    
    func loadUsers() {

        if dataUsers.isEmpty {
            let allUsersRef = db.collection(K.FStore.collectionUsersName)
            allUsersRef.whereField(K.FStore.friendsField, arrayContains: currentUserID)
                .getDocuments { (querySnapshot, error) in
                    if let err = error {
                        print("Error getting documents: \(err)")
                    } else {
                        // documents exist in Firestore
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                 if let pseudo = data[K.FStore.pseudoField] as? String, let avatar = data[K.FStore.avatarField] as? String {
                                    let newUser = User(pseudo: pseudo, avatar: avatar, id: doc.documentID)
                                    self.dataUsers.append(newUser)
                                    
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        self.competitorsLabel.text = "FRIENDS:"
                                        self.competitorsLabel.textAlignment = .left
                                    }
                                 }
                            }
                        } // fin if let snapshotDoc
                    } // fin else no error ...so access data possible
                } // fin getDocument
        }
    }

    
    @IBAction func accountPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.segueHomeToAccount, sender: self)
    }


    @IBAction func logOutPressed(_ sender: UIButton) {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
            return
        }
        if Auth.auth().currentUser == nil {
            // Remove User Session from device
            UserDefaults.standard.removeObject(forKey: "USER_KEY_UID")
            UserDefaults.standard.synchronize()
        print("user logged out")
        self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func addFriendsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.segueGoToAddFriends, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueHomeToAccount {
            let accountView = segue.destination as! AccountViewController
            accountView.pseudo = pseudoCurrentUser
            accountView.avatarImage = avatarCurrentUser
            accountView.userID = currentUserID
            accountView.accountDelegate = self
        }
        else if segue.identifier == K.segueGoToAddFriends {
            let addFriendsView = segue.destination as! AddFriendsTableViewController
            addFriendsView.currentUserID = currentUserID
            addFriendsView.dataUsers = dataUsers
            addFriendsView.addFriendDelegate = self
        }
        else if segue.identifier == K.segueGoToFriendActivity {
            let friendActivityView = segue.destination as! FriendActivityViewController
            friendActivityView.friendID = friendID
            friendActivityView.friendAvatar = friendAvatar
            friendActivityView.friendPseudo = friendPseudo
        }
    }

    
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.userCell.userCellIdentifier, for: indexPath) as! UserCell
        cell.avatarImage.image = UIImage(named: dataUsers[indexPath.row].avatar)
        cell.userLabel.text = dataUsers[indexPath.row].pseudo
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friendAvatar = dataUsers[indexPath.row].avatar
        friendPseudo = dataUsers[indexPath.row].pseudo
        friendID = dataUsers[indexPath.row].id
        print(friendAvatar)
        print(friendPseudo)
        print(friendID)
        performSegue(withIdentifier: K.segueGoToFriendActivity, sender: self)
    }
    
}


extension ProfileViewController: accountViewDelegate {
    func sendDataBackToProfileVC(pseudo: String, avatar: String) {
        pseudoCurrentUser = pseudo
        avatarCurrentUser = avatar
    }
}

extension ProfileViewController: addFriendViewDelegate {
    func sendFriendsBackToProfileVC(friendsArray: [User]) {
        dataUsers = friendsArray
        self.tableView.reloadData()
    }
}
