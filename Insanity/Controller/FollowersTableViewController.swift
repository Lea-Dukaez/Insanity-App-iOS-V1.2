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
    var currentUserID: String = ""
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        print(currentUserID)
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: K.userCell.addFriendCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.addFriendCellIdentifier)
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table View DataSource


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if followerUsers.count != 0 {
            return followerUsers.count
        } else {
            return 1
        }
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellForRowAt called to load data")
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: K.userCell.addFriendCellIdentifier, for: indexPath) as! AddFriendCell

        if followerUsers.count != 0 {
            
            cell.avatarImage.image = UIImage(named: followerUsers[indexPath.row].avatar)
            cell.pseudolabel.text = followerUsers[indexPath.row].pseudo
            cell.userID = followerUsers[indexPath.row].id
            cell.userStatus = followerUsers[indexPath.row].status
            cell.addButton.titleLabel?.textAlignment = .center

            if followerUsers[indexPath.row].status == K.FStore.Relationships.statusWaitingApproval {
                cell.addButton.setTitle("Waiting", for: .normal)
                cell.addButton.backgroundColor = UIColor(named: K.BrandColor.orangeBrancColor)
            } else {
                cell.addButton.setTitle("Delete", for: .normal)
                cell.addButton.backgroundColor = .label
            }
            
            
        } else {
            // No follower
            cell.avatarImage.image = UIImage()
            cell.pseudolabel.text = "No follower yet"
            cell.pseudolabel.textAlignment = .center
            cell.addButton.isEnabled = false
            cell.addButton.setTitle("", for: .normal)
            cell.addButton.backgroundColor = .clear
        }
        
        // implement the button action for cell
        cell.user = { userIDAdded in
            
            let userSelectedArray = self.followerUsers.filter( { $0.id.contains(userIDAdded!) } )
            let userSelected = userSelectedArray[0]
            
            if cell.addButton.titleLabel?.text == "Waiting" {
                // case: approve or reject follower request
                let alert = UIAlertController(title: "Accept Follower", message: "", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.followerUsers[indexPath.row].status = K.FStore.Relationships.statusFollowing
                    self.updateFollower(userID: userIDAdded!, accepted: true)
                    self.tableView.reloadData()
                }))

                alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action: UIAlertAction!) in
                    
                    if let index = self.followerUsers.firstIndex(of: userSelected){
                        self.followerUsers.remove(at: index)
                    }
                    self.updateFollower(userID: userIDAdded!, accepted: false)
                    self.tableView.reloadData()
                }))
                
                self.present(alert, animated: true) {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
                    alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                }
                
            }
            else {
                // case : Delete user from follower
                if let index = self.followerUsers.firstIndex(of: userSelected){
                    self.followerUsers.remove(at: index)
                }
                self.updateFollower(userID: userIDAdded!, accepted: false)
                self.tableView.reloadData()
            }

        }

        
        return cell
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Section DataBase Interactions
    
    func updateFollower(userID: String, accepted: Bool) {

        let userUpdatedRef = db.collection(K.FStore.Users.collectionUsersName).document(userID)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userUpdatedDocument: DocumentSnapshot
            do {
                try userUpdatedDocument = transaction.getDocument(userUpdatedRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var oldFollowedUsers = userUpdatedDocument.data()?[K.FStore.Users.followedUsersField] as? [String:String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve followedUsers from snapshot \(userUpdatedRef)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            var newFollowedUsers : [String:String] = [:]
            if accepted {
                oldFollowedUsers[self.currentUserID] = K.FStore.Relationships.statusFollowing
                newFollowedUsers = oldFollowedUsers
                transaction.updateData([K.FStore.Users.followedUsersField: newFollowedUsers], forDocument: userUpdatedRef)
            } else {
                oldFollowedUsers.removeValue(forKey: self.currentUserID)
                newFollowedUsers = oldFollowedUsers
                transaction.updateData([K.FStore.Users.followedUsersField: newFollowedUsers], forDocument: userUpdatedRef)
            }
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }


 
}
