//
//  DataBrain.swift
//  Insanity
//
//  Created by Léa on 30/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation
import Firebase

class DataBrain {
    let db = Firestore.firestore()
    var currentUserID: String = ""
    var dataPodium: [PodiumCompetitor] = []
    var currentUserMaxValues: [Double] = []
    var userMaxValues: [Double] = []
    
    func recupPodiumMaxValues() {
        dataPodium = []

        db.collection(K.FStore.collectionUsersName)
            .addSnapshotListener { (querySnapshot, error) in
                if let err = error {
                    print("Error retrieving document: \(err)")
                    return
                } else if (querySnapshot?.isEmpty)! {
                    print("no data")
                    return
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            let userID = doc.documentID
                            if let maxValues = data[K.FStore.maxField] as? [Double], let avatar = data[K.FStore.avatarField] as? String, let pseudo = data[K.FStore.pseudoField] as? String, let friends = data[K.FStore.friendsField] as? [String] {
                                // get only data for current user and friends
                                if (userID == self.currentUserID) || friends.filter( { $0.contains(self.currentUserID) } ).isEmpty == false {
                                    let podiumCompetitor = PodiumCompetitor(pseudo: pseudo, avatar: avatar, max: maxValues, userID: userID)
                                    self.dataPodium.append(podiumCompetitor)
                                }
                            } // end if let get data
                        } // end for loop
                    } // end if let snapshotdocuments
                }
        }
    }
    
    
    func recupUserMax(uid: String) {
        db.collection(K.FStore.collectionUsersName).document(uid)
            .getDocument { (document, error) in
                if let err = error {
                    print("Error retrieving document: \(err)")
                    return
                } else {
                    if let doc = document, doc.exists {
                        if let data = doc.data() {
                            if let maxValues = data[K.FStore.maxField] as? [Double] {
                                if uid == self.currentUserID {
                                    self.currentUserMaxValues = maxValues
                                } else {
                                    self.userMaxValues = maxValues
                                }
                                
                            }
                        }
                    }
                }
        }
    }
    
    
}
