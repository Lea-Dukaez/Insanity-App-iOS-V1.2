//
//  DataBrain.swift
//  Insanity
//
//  Created by Léa on 30/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation
import Firebase

protocol dataBrainClassDelegate {
    func getUserWorkoutInfo()
}

class DataBrain {
    static let sharedInstance = DataBrain()

    let db = Firestore.firestore()
    
    var isLoggedIn: Bool = false

    var currentUserID: String = ""
    var avatarCurrentUser: String = ""
    var pseudoCurrentUser: String = ""
    var dataFollowedUsers: [String:String] = [:]
    
    var dataPodium: [PodiumCompetitor] = []
    var currentUserMaxValues: [Double] = []
    
    var dataBrainDelegate: dataBrainClassDelegate?
    var userMaxValues: [Double] = [] {
        didSet{
            self.dataBrainDelegate?.getUserWorkoutInfo()
        }
    }


    func getCurrentUser() {
        print("DataBrain getCurrentUser called")
        self.db.collection(K.FStore.Users.collectionUsersName).document(currentUserID)
            .getDocument { (document, error) in
            if let doc = document {
                if let data = doc.data() {
                    if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                        let avatar = data[K.FStore.Users.avatarField] as? String,
                        let followedUsers = data[K.FStore.Users.followedUsersField] as? [String:String],
                        let maxValues = data[K.FStore.Users.maxField] as? [Double] {
                        
                        self.currentUserMaxValues = maxValues
                        self.dataFollowedUsers = followedUsers
                        self.pseudoCurrentUser = pseudo
                        self.avatarCurrentUser = avatar
                    }
                }
            }
        }
    }
    
    // MARK: - Methods for Sign Up VC
    
    func createUserInfo(pseudoDefault: String, avatarDefault: String) {
        let calendar: [Bool] = Array(repeating: false, count: 72)
        // Add a new document in Firestore for new user
        db.collection(K.FStore.Users.collectionUsersName).document(self.currentUserID).setData([
            K.FStore.Users.maxField: [Double](),
            K.FStore.Users.followedUsersField: [String:String](),
            K.FStore.Users.calendarField:calendar,
            K.FStore.Users.pseudoField: pseudoDefault,
            K.FStore.Users.nameSearchField: pseudoDefault.lowercased(),
            K.FStore.Users.avatarField: avatarDefault
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }
    }
    
    // MARK: - Methods for Account VC
    
    func changePseudoAndImage() {
        self.db.collection(K.FStore.Users.collectionUsersName).document(self.currentUserID).updateData([
            K.FStore.Users.pseudoField: self.pseudoCurrentUser ,
            K.FStore.Users.nameSearchField: self.pseudoCurrentUser.lowercased(),
            K.FStore.Users.avatarField: self.avatarCurrentUser
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }
    }
    
    func recupPodiumMaxValues() {
        dataPodium = []

        db.collection(K.FStore.Users.collectionUsersName)
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
                        if let maxValues = data[K.FStore.Users.maxField] as? [Double],
                            let avatar = data[K.FStore.Users.avatarField] as? String,
                            let pseudo = data[K.FStore.Users.pseudoField] as? String {
                            
                            // get only data for current user and followed friends
                            if (userID == self.currentUserID) || self.dataFollowedUsers[userID] == K.FStore.Relationships.statusFollowing {
                                let podiumCompetitor = PodiumCompetitor(pseudo: pseudo, avatar: avatar, max: maxValues, userID: userID)
                                print(podiumCompetitor)
                                self.dataPodium.append(podiumCompetitor)
                            }
                        }
                    }
                }
            }
        }
    }
    
//    func recupPodiumMaxValuesNew() {
//        dataPodium = []
//
//        let currentUserRef = db.collection(K.FStore.Users.collectionUsersName).document(self.currentUserID)
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let currentUserDocument: DocumentSnapshot
//            do {
//                try currentUserDocument = transaction.getDocument(currentUserRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            guard let followedUsers = currentUserDocument.data()?[K.FStore.Users.followedUsersField] as? [String:String],
//                let currentUserMax = currentUserDocument.data()?[K.FStore.Users.maxField] as? [Double] else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve followedUsers from snapshot \(currentUserRef)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//
//            let podiumCompetitor = PodiumCompetitor(pseudo: pseudo, avatar: avatar, max: maxValues, userID: userID)
//            self.dataPodium.append(podiumCompetitor)
//
//            let keys: [String] = followedUsers.map({ $0.key })
//            for key in keys {
//
//                let followedUserRef = self.db.collection(K.FStore.Users.collectionUsersName).document(key)
//
//                let followedUserDocument: DocumentSnapshot
//                do {
//                    try followedUserDocument = transaction.getDocument(followedUserRef)
//                } catch let fetchError as NSError {
//                    errorPointer?.pointee = fetchError
//                    return nil
//                }
//
//                guard var followedUserMax = followedUserDocument.data()?[K.FStore.Users.maxField] as? [Double] else {
//                    let error = NSError(
//                        domain: "AppErrorDomain",
//                        code: -1,
//                        userInfo: [
//                            NSLocalizedDescriptionKey: "Unable to retrieve followedUsers from snapshot \(currentUserRef)"
//                        ]
//                    )
//                    errorPointer?.pointee = error
//                    return nil
//                }
//            }
//
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Transaction successfully committed!")
//            }
//        }
//    }
//
    
    func recupUserMax(uid: String? = nil) {
        let userID = uid ?? self.currentUserID
        
        db.collection(K.FStore.Users.collectionUsersName).document(userID)
            .getDocument { (document, error) in
                if let err = error {
                    print("Error retrieving document: \(err)")
                    return
                } else {
                    if let doc = document, doc.exists {
                        if let data = doc.data() {
                            if let maxValues = data[K.FStore.Users.maxField] as? [Double] {
                                if userID == self.currentUserID {
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
    
    
    // MARK: - Methods for Test View Controller
    
    func saveNewWorkout(testResults: [Double], workoutDate: Date) {
        self.db.collection(K.FStore.WorkoutTests.collectionTestName).addDocument(data: [
            K.FStore.WorkoutTests.idField: self.currentUserID,
            K.FStore.WorkoutTests.testField: testResults,
            K.FStore.WorkoutTests.dateField: Timestamp(date: workoutDate)
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            } else {
                print("Document added!")
            }
        }
    }
    
    func majMax(listTest: [Double]) {
        var newMaxValues: [Double] = []
        
        let userRef = db.collection(K.FStore.Users.collectionUsersName).document(self.currentUserID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
             try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldMaxValues = userDocument.data()?[K.FStore.Users.maxField] as? [Double] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve maxValue from snapshot \(userDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            // if it is the first time the user do the test
            if oldMaxValues.isEmpty {
                transaction.updateData([K.FStore.Users.maxField: listTest], forDocument: userRef)
                return nil
            } else {
                for index in 0..<oldMaxValues.count {
                    newMaxValues.append(max(listTest[index], oldMaxValues[index]))
                }
                transaction.updateData([K.FStore.Users.maxField: newMaxValues], forDocument: userRef)
                return nil
            }
            
        }) { (object, error) in
            if let err = error {
                print("Transaction failed: \(err)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }

    
    
}
