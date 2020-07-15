//
//  FollowersTableViewController.swift
//  Insanity
//
//  Created by Léa on 06/07/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase

class FollowersTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    var followerUsers: [User] = []
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: K.userCell.addFriendCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.addFriendCellIdentifier)
        self.tableView.tableFooterView = UIView()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if followerUsers.count != 0 {
            return followerUsers.count
        } else {
            return 1
        }
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: K.userCell.addFriendCellIdentifier, for: indexPath) as! AddFriendCell

        if followerUsers.count != 0 {
            
            cell.avatarImage.image = UIImage(named: followerUsers[indexPath.row].avatar)
            cell.pseudolabel.text = followerUsers[indexPath.row].pseudo
            cell.userID = followerUsers[indexPath.row].id
            cell.userStatus = followerUsers[indexPath.row].status
            cell.addButton.titleLabel?.textAlignment = .center

            if followerUsers[indexPath.row].status == K.FStore.Relationships.statusWaitingApproval {
                cell.addButton.setTitle("Waiting Approval", for: .normal)
                cell.addButton.backgroundColor = UIColor.systemGray
            } else {
                cell.addButton.setTitle("Delete", for: .normal)
            }
            
            
        } else {
            cell.avatarImage.image = UIImage()
            cell.pseudolabel.text = "No follower yet"
        }
        
        // implement the button action for cell
        cell.user = { userIDAdded in
            
            if cell.addButton.titleLabel?.text == "Waiting Approval" {
                // case: approve or not follower request
                print("click to approve or refuse request")
                
//                userAdded.status = K.FStore.Relationships.statusWaitingApproval
//                cell.userStatus = K.FStore.Relationships.statusWaitingApproval
//                self.dataUsers.append(userAdded)
//                self.friendsIDArray[userIDAdded!] = userAdded.status
                
                
            }
            else {
                print("click to Delete from follower")
                // case: End following relationship OR case: cancel add/follow action
//                if let index = self.dataUsers.firstIndex(of: userAdded) {
//                    let removedFriend = self.dataUsers.remove(at: index)
//
//
//                    self.friendsIDArray[removedFriend.id] = nil
//                }
            }
//
//            self.updatefollowedUsersOfCurrentUser()
//            self.tableView.reloadData()
        }

        
        return cell
    }
    
//    func updatefollowedUsersOfSelectedUser() {
//        let currentUserRef = db.collection(K.FStore.Users.collectionUsersName).document(currentUserID)
//
//        currentUserRef.updateData([
//            K.FStore.Users.followedUsersField : friendsIDArray
//        ]) { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//            }
//        }
//        self.addFriendDelegate?.sendFriendsBackToProfileVC(friendsArray: dataUsers, friendsIDArray: friendsIDArray)
//        
//    }


 
}
