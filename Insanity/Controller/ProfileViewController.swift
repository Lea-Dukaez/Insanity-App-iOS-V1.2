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
    
    var dataFollowedUsers: [String:String] = [:] {
        didSet {
            print("dataFollowedUsers has been set")
            
            let nbFollowing = dataFollowedUsers.allKeys(forValue: K.FStore.Relationships.statusFollowing)
            self.followingButton.titleLabel?.text = "\(nbFollowing.count)\nFollowing"
            
            loadUsers()
        }
    }
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!    
    @IBOutlet weak var followerToApproveImage: UIImageView!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true);

        followingButton.isEnabled = false
        addFriendsButton.backgroundColor = .clear
        addFriendsButton.layer.borderWidth = 1
        addFriendsButton.layer.borderColor = UIColor(named: K.BrandColor.orangeBrancColor)?.cgColor
        addFriendsButton.layer.cornerRadius = 3
        logOutButton.backgroundColor = .clear
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.cornerRadius = 3
        logOutButton.layer.borderColor = UIColor.label.cgColor
        
        getCurrentUser()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: K.userCell.userCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.userCellIdentifier)
        self.tableView.tableFooterView = UIView()
        
//        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.currentUserLabel.text = self.pseudoCurrentUser
        self.currentUserImage.image = UIImage(named: self.avatarCurrentUser)
    }
    
    // MARK: - Section DataBase Interactions
    
    func getCurrentUser() {
        self.db.collection(K.FStore.Users.collectionUsersName).document(currentUserID)
            .getDocument { (document, error) in
            if let doc = document {
                if let data = doc.data() {
                    if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                        let avatar = data[K.FStore.Users.avatarField] as? String,
                        let followedUsers = data[K.FStore.Users.followedUsersField] as? [String:String] {
                        
                        self.dataFollowedUsers = followedUsers
                        print(self.dataFollowedUsers)
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
        print("inside loadUsers ")
        
        if dataUsers.isEmpty {
            
            let allUsersRef = db.collection(K.FStore.Users.collectionUsersName)
            allUsersRef.getDocuments { (querySnapshot, error) in
                    if let err = error {
                    print("Error getting documents: \(err)")

                    } else {
                    // documents exist in Firestore
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            
                            if self.dataFollowedUsers.keys.contains(doc.documentID) {
                                
                                let data = doc.data()
                                if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                                    let avatar = data[K.FStore.Users.avatarField] as? String,
                                    let nameSearch = data[K.FStore.Users.nameSearchField] as? String {

                                    let newUser = User(pseudo: pseudo, nameSearch: nameSearch, avatar: avatar, id: doc.documentID, status: self.dataFollowedUsers[doc.documentID]!)
                                    self.dataUsers.append(newUser)

                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
                                        // Update nb of folloung user ?
                                        
//                                        let following = self.dataUsers.filter({ $0.status == K.FStore.Relationships.statusFollowing})
//                                        self.followingButton.titleLabel?.text = "\(following.count)\n Following"


    //                                    self.competitorsLabel.text = "FRIENDS:"
    //                                    self.competitorsLabel.textAlignment = .left
                                    }
                                 }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Section Buttons Action
    
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
    
    @IBAction func followerPressed(_ sender: UIButton) {
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
            addFriendsView.friendsIDArray = dataFollowedUsers
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
//        return dataUsers.count
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
//        let keys = dataFollowedUsers.allKeys(forValue: K.FStore.Relationships.statusFollowing)
        return following.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.userCell.userCellIdentifier, for: indexPath) as! UserCell
        
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
        
        cell.avatarImage.image = UIImage(named: following[indexPath.row].avatar)
        cell.userLabel.text = following[indexPath.row].pseudo
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
        
        friendAvatar = following[indexPath.row].avatar
        friendPseudo = following[indexPath.row].pseudo
        friendID = following[indexPath.row].id
        performSegue(withIdentifier: K.segueGoToFriendActivity, sender: self)
    }
    
}

// MARK: - Section Delegates - Protocoles

extension ProfileViewController: accountViewDelegate {
    func sendDataBackToProfileVC(pseudo: String, avatar: String) {
        pseudoCurrentUser = pseudo
        avatarCurrentUser = avatar
    }
}

extension ProfileViewController: addFriendViewDelegate {
    func sendFriendsBackToProfileVC(friendsArray: [User], friendsIDArray : [String:String]) {
        dataUsers = friendsArray
        dataFollowedUsers = friendsIDArray
        self.tableView.reloadData()
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
