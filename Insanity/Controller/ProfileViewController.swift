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
        
    var currentUserID = ""
    
    var friendPseudo = ""
    var friendAvatar = ""
    var friendID = ""
    
    var dataUsers: [User] = []
    var followerUsers: [User] = []
    
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

        followingButton.titleLabel?.numberOfLines = 0
        followingButton.isEnabled = false
        
        addFriendsButton.backgroundColor = .clear
        addFriendsButton.layer.borderWidth = 1
        addFriendsButton.layer.borderColor = UIColor(named: K.BrandColor.orangeBrancColor)?.cgColor
        addFriendsButton.layer.cornerRadius = 3
        
        logOutButton.backgroundColor = .clear
        logOutButton.layer.borderWidth = 1
        logOutButton.layer.cornerRadius = 3
        logOutButton.layer.borderColor = UIColor.label.cgColor
        
        currentUserID = DataBrain.sharedInstance.currentUserID
        
        loadUsers()

        getFollower()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: K.userCell.userCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.userCellIdentifier)
        self.tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nbFollowing = DataBrain.sharedInstance.dataFollowedUsers.allKeys(forValue: K.FStore.Relationships.statusFollowing)
        
        self.followingButton.setTitle("\(nbFollowing.count)\nFollowing", for: .normal)
        self.currentUserLabel.text = DataBrain.sharedInstance.pseudoCurrentUser
        self.currentUserImage.image = UIImage(named: DataBrain.sharedInstance.avatarCurrentUser)
    }
    
    // MARK: - Section DataBase Interactions
    
    func loadUsers() {
        db.collection(K.FStore.Users.collectionUsersName)
            .addSnapshotListener { (querySnapshot, error) in
                if let err = error {
                print("Error getting documents: \(err)")

                } else {
                // documents exist in Firestore
                self.dataUsers = []
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        // get Followed Users
                        if DataBrain.sharedInstance.dataFollowedUsers.keys.contains(doc.documentID) {
                            
                            let data = doc.data()
                            
                            if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                                let avatar = data[K.FStore.Users.avatarField] as? String,
                                let nameSearch = data[K.FStore.Users.nameSearchField] as? String {

                                let newUser = User(pseudo: pseudo, nameSearch: nameSearch, avatar: avatar, id: doc.documentID, status: DataBrain.sharedInstance.dataFollowedUsers[doc.documentID]!)
                                self.dataUsers.append(newUser)

                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                             }
                        }
                    }
                }
            }
        }
    }
    
    func getFollower() {
        db.collection(K.FStore.Users.collectionUsersName)
            .addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print("Error retrieving document: \(err)")
                return
            }
             else {
                self.followerUsers = []
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        let userID = doc.documentID

                        // get Followers
                        if let followedUsers = data[K.FStore.Users.followedUsersField] as? [String:String],
                            let pseudo = data[K.FStore.Users.pseudoField] as? String,
                            let avatar = data[K.FStore.Users.avatarField] as? String,
                            let nameSearch = data[K.FStore.Users.nameSearchField] as? String
                        {
                            if (userID != self.currentUserID) && (followedUsers[self.currentUserID] != nil) {
                                
                                let newUser = User(pseudo: pseudo, nameSearch: nameSearch, avatar: avatar, id: doc.documentID, status: followedUsers[self.currentUserID]!)
                                self.followerUsers.append(newUser)
                            }
                       }
                        
                        DispatchQueue.main.async {
                            let nbFollower: [User] = self.followerUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
                            let nbFollowerToApprove: [User] = self.followerUsers.filter( { $0.status.contains(K.FStore.Relationships.statusWaitingApproval) } )

                            self.followerButton.setTitle("\(nbFollower.count)\nFollower", for: .normal)
                            if nbFollowerToApprove.count == 0 {
                                self.followerToApproveImage.image = UIImage()
                            } else {
                                self.followerToApproveImage.image = UIImage(systemName: "\(nbFollowerToApprove.count).square.fill")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Section Buttons Action
    
    @IBAction func accountPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.ProfileVC.segueProfileToSettings, sender: self)
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
            DataBrain.sharedInstance.isLoggedIn = false
//            UserDefaults.standard.removeObject(forKey: "USER_KEY_UID")
//            UserDefaults.standard.synchronize()
            DataBrain.sharedInstance.allWorkOutResultsCurrentUser = []
            print("user logged out")
            DispatchQueue.main.async {
                self.navigationController!.popToRootViewController(animated: true)
            }
        
        }
    }
    
    @IBAction func followerPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.ProfileVC.segueGoToFollowers, sender: self)
    }
    
    @IBAction func addFriendsPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.ProfileVC.segueGoToAddFriends, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.ProfileVC.segueGoToAddFriends {
            let addFriendsView = segue.destination as! AddFriendsTableViewController
            addFriendsView.currentUserID = currentUserID
            addFriendsView.dataUsers = dataUsers
            addFriendsView.addFriendDelegate = self
        }
        else if segue.identifier == K.Segue.ProfileVC.segueGoToFriendActivity {
            let friendActivityView = segue.destination as! FriendActivityViewController
            friendActivityView.friendID = friendID
            friendActivityView.friendAvatar = friendAvatar
            friendActivityView.friendPseudo = friendPseudo
        }
        else if segue.identifier == K.Segue.ProfileVC.segueGoToFollowers {
            let followersView = segue.destination as! FollowersTableViewController
            followersView.followerUsers = followerUsers
            followersView.currentUserID = currentUserID 
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
        if following.count != 0 {
           return following.count
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.userCell.userCellIdentifier, for: indexPath) as! UserCell
        
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
        
        if following.count != 0 {
            cell.avatarImage.image = UIImage(named: following[indexPath.row].avatar)
            cell.userLabel.text = following[indexPath.row].pseudo

        } else {
            cell.avatarImage.image = UIImage()
            cell.userLabel.text = "Following no friends for now"
        }
        
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let following = self.dataUsers.filter( { $0.status.contains(K.FStore.Relationships.statusFollowing) } )
        
        if following.count != 0 {
            friendAvatar = following[indexPath.row].avatar
            friendPseudo = following[indexPath.row].pseudo
            friendID = following[indexPath.row].id
            DataBrain.sharedInstance.recupUserMax(uid: friendID)
            performSegue(withIdentifier: K.Segue.ProfileVC.segueGoToFriendActivity, sender: self)
        }
    }
    
}

// MARK: - Section Delegates - Protocoles

extension ProfileViewController: addFriendViewDelegate {
    func sendFriendsBackToProfileVC(friendsArray: [User], friendsIDArray : [String:String]) {
        dataUsers = friendsArray
        self.tableView.reloadData()
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}
