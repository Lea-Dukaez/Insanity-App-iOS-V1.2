//
//  AddFriendsTableViewController.swift
//  Insanity
//
//  Created by Léa on 16/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

protocol addFriendViewDelegate {
    func sendFriendsBackToProfileVC(friendsArray: [User], friendsIDArray : [String:String])
}

class AddFriendsTableViewController: UITableViewController {
    
    var addFriendDelegate: addFriendViewDelegate?
    let db = Firestore.firestore()
    var currentUserID = ""
    
    var friendsIDArray : [String:String] = [:]
    var allUsersArray: [User] = []
    var matchingUsersArray = [User]()
    var dataUsers: [User] = []

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsIDArray = DataBrain.sharedInstance.dataFollowedUsers
        
        searchBar.delegate = self
        self.tableView.register(UINib(nibName: K.userCell.addFriendCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.addFriendCellIdentifier)
        self.tableView.tableFooterView = UIView()
        searchBar.placeholder = "Search a pseudo"
    }
    

    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingUsersArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: K.userCell.addFriendCellIdentifier, for: indexPath) as! AddFriendCell

        let userID = matchingUsersArray[indexPath.row].id
        cell.avatarImage.image = UIImage(named: matchingUsersArray[indexPath.row].avatar)
        cell.pseudolabel.text = matchingUsersArray[indexPath.row].pseudo
        cell.userID = userID
        cell.userStatus = matchingUsersArray[indexPath.row].status
        cell.addButton.titleLabel?.textAlignment = .center
        
        if self.dataUsers.filter( { $0.id.contains(userID) } ).isEmpty == false {
            // case user is already added as "friends"
            if self.dataUsers.filter( { $0.id.contains(userID) } )[0].status == K.FStore.Relationships.statusWaitingApproval {
                cell.userStatus = K.FStore.Relationships.statusWaitingApproval
                cell.addButton.setTitle("Waiting", for: .normal)
                cell.addButton.backgroundColor = UIColor.systemGray
            } else {
                cell.userStatus = K.FStore.Relationships.statusFollowing
                cell.addButton.setTitle("Unfollow", for: .normal)
                cell.addButton.backgroundColor = UIColor(named: K.BrandColor.orangeBrancColor)
            }
        } else {
            cell.addButton.setTitle("Follow", for: .normal)
            cell.addButton.backgroundColor = .label
        }

        
        // implement the button action for cell
        cell.user = { userIDAdded in
            
            let userAddedArray = self.allUsersArray.filter( { $0.id.contains(userIDAdded!) } )
            var userAdded = userAddedArray[0]
            
            if cell.addButton.titleLabel?.text == "Follow" {
                // case: ask approval for following
                userAdded.status = K.FStore.Relationships.statusWaitingApproval
                cell.userStatus = K.FStore.Relationships.statusWaitingApproval
                self.dataUsers.append(userAdded)
                self.friendsIDArray[userIDAdded!] = userAdded.status
            
            }
            else {
                // case: End following relationship OR case: cancel add/follow action
                if let index = self.dataUsers.firstIndex(of: userAdded) {
                    let removedFriend = self.dataUsers.remove(at: index)
                    self.friendsIDArray[removedFriend.id] = nil
                }
            }
            
            self.updatefollowedUsersOfCurrentUser()
            self.tableView.reloadData()
        }
        
        return cell
    }
    
    // MARK: - Section DataBase Interactions
    
    func updatefollowedUsersOfCurrentUser() {
        let currentUserRef = db.collection(K.FStore.Users.collectionUsersName).document(currentUserID)

        currentUserRef.updateData([
            K.FStore.Users.followedUsersField : friendsIDArray
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        DataBrain.sharedInstance.dataFollowedUsers = friendsIDArray
        
        self.addFriendDelegate?.sendFriendsBackToProfileVC(friendsArray: dataUsers, friendsIDArray: friendsIDArray)
        
    }


    func searchForFriends(for searchWord: String) {
        allUsersArray = []

        self.db.collection(K.FStore.Users.collectionUsersName)
            .whereField(K.FStore.Users.nameSearchField, isGreaterThanOrEqualTo: searchWord)
            .limit(to: 10)
            .getDocuments { (querySnapshot, error) in
                if let err = error {
                print("Error getting documents: \(err)")
                } else {
                // documents exist in Firestore
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                            let avatar = data[K.FStore.Users.avatarField] as? String,
                            let nameSearch = data[K.FStore.Users.nameSearchField] as? String {
                
                            if doc.documentID != self.currentUserID {
                                
                                let status = self.friendsIDArray[doc.documentID] ?? "nul"
                                
                                let newUser = User(pseudo: pseudo, nameSearch: nameSearch, avatar: avatar, id: doc.documentID, status: status)
                                
                                self.allUsersArray.append(newUser)
                                
                                DispatchQueue.main.async {
                                    self.matchingUsersArray = self.allUsersArray.filter( { $0.nameSearch.contains(searchWord) } )
                                    self.tableView.reloadData()
                                }
                            }
                         }
                    }
                }
            }
        }
    }
}

// MARK: - Section UISearchBarDelegate

extension AddFriendsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchWord = searchBar.text!.lowercased()
        searchForFriends(for: searchWord)
    }
    
}
