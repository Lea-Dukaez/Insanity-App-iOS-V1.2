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
    func sendFriendsBackToProfileVC(friendsArray: [User])
}

class AddFriendsTableViewController: UITableViewController {
    
    var addFriendDelegate: addFriendViewDelegate?
    let db = Firestore.firestore()
    var currentUserID = ""
    
    var friendsIDArray : [String] = []
    var allUsersArray: [User] = []
    var matchingUsersArray = [User]()
    var dataUsers: [User] = [] {
        didSet {
            updateFriendsIDArray()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        super.viewDidLoad()

        getUsers()
        
        searchBar.delegate = self
        self.tableView.register(UINib(nibName: K.userCell.addFriendCellNibName, bundle: nil), forCellReuseIdentifier: K.userCell.addFriendCellIdentifier)
        self.tableView.tableFooterView = UIView()
        searchBar.placeholder = "Search a pseudo"
    }
    
    func updateFriendsIDArray() {
        for user in dataUsers {
            friendsIDArray.append(user.id)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingUsersArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCell(withIdentifier: K.userCell.addFriendCellIdentifier, for: indexPath) as! AddFriendCell

        let userID = matchingUsersArray[indexPath.row].id
        cell.avatarImage.image = UIImage(named: matchingUsersArray[indexPath.row].avatar)
        cell.pseudolabel.text = matchingUsersArray[indexPath.row].pseudo
        cell.userID = userID
        
        if self.dataUsers.filter( { $0.id.contains(userID) } ).isEmpty == false {
            // case user is already added as "friends"
            cell.addButton.setTitle("Remove", for: .normal)
            cell.addButton.backgroundColor = .red
        } else {
            cell.addButton.setTitle("Add", for: .normal)
            cell.addButton.backgroundColor = .label
        }

        cell.user = { userIDAdded in
            let userAdded = self.allUsersArray.filter( { $0.id.contains(userIDAdded!) } )
            if cell.addButton.titleLabel?.text == "Add" {
                self.dataUsers.append(userAdded[0])
                self.friendsIDArray.append(userAdded[0].id)
                print("hello1")
                self.updateOtherUsersFriends(userID: userIDAdded!, added: true)
            } else {
                print("hello2")
                if let index = self.dataUsers.firstIndex(of: userAdded[0]) {
                    let removedFriend = self.dataUsers.remove(at: index)
                    if let indexRemoved = self.friendsIDArray.firstIndex(of: removedFriend.id) {
                        self.friendsIDArray.remove(at: indexRemoved)
                    }
                }
                self.updateOtherUsersFriends(userID: userIDAdded!, added: false)
            }
            
            self.updateFriendsCurrentUser()
            self.tableView.reloadData()
        }
        
        return cell
    }
    
    func updateFriendsCurrentUser() {
        let currentUserRef = db.collection(K.FStore.collectionUsersName).document(currentUserID)
        
        currentUserRef.updateData([
            K.FStore.friendsField : friendsIDArray
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        self.addFriendDelegate?.sendFriendsBackToProfileVC(friendsArray: dataUsers)
    }
    
    func updateOtherUsersFriends(userID: String, added: Bool) {
        print("inside updateOtherUsersFriends for user : \(userID)")
        
        let otherUsersRef = db.collection(K.FStore.collectionUsersName).document(userID)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let otherUserDocument: DocumentSnapshot
            do {
                try otherUserDocument = transaction.getDocument(otherUsersRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var oldFriends = otherUserDocument.data()?[K.FStore.friendsField] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve friends from snapshot \(otherUsersRef)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }

            var newFriends : [String] = []
            if added {
                oldFriends.append(self.currentUserID)
                newFriends = oldFriends
                transaction.updateData([K.FStore.friendsField: newFriends], forDocument: otherUsersRef)
            } else {
                if let indexToRemove = oldFriends.firstIndex(of: self.currentUserID) {
                    oldFriends.remove(at: indexToRemove)
                    newFriends = oldFriends
                }
                transaction.updateData([K.FStore.friendsField: newFriends], forDocument: otherUsersRef)
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
    

    func getUsers() {
        allUsersArray = []

        self.db.collection(K.FStore.collectionUsersName)
            .getDocuments { (querySnapshot, error) in
                if let err = error {
                    print("Error getting documents: \(err)")
                } else {
                    // documents exist in Firestore
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                             if let pseudo = data[K.FStore.pseudoField] as? String, let avatar = data[K.FStore.avatarField] as? String {
                                if doc.documentID != self.currentUserID {
                                    let newUser = User(pseudo: pseudo, avatar: avatar, id: doc.documentID)
                                    self.allUsersArray.append(newUser)
                                }
                             }
                        }
                    } // fin if let snapshotDoc
                } // fin else no error ...so access data possible
            } // fin getDocument
    }

    

}

extension AddFriendsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        matchingUsersArray = allUsersArray.filter( { $0.pseudo.contains(searchBar.text!) } )

        tableView.reloadData()
    }
}
