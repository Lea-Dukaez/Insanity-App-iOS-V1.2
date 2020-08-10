//
//  DataBrain.swift
//  Insanity
//
//  Created by Léa on 30/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation
import Firebase

protocol dataBrainUserMaxValuesDelegate {
    func getUserWorkoutInfo()
}

protocol dataBrainCalendarDelegate {
    func getCalendar()
}

protocol dataBrainLogInDelegate {
    func getCurrentUserOK()
}

protocol DataBrainProgressDelegate {
    func updateProgressChart()
}

class DataBrain {
    static let sharedInstance = DataBrain()

    let db = Firestore.firestore()
    
    var isLoggedIn: Bool = false

    var currentUserID: String = ""
    var avatarCurrentUser: String = ""
    var pseudoCurrentUser: String = ""
    var dataFollowedUsers: [String:String] = [:]
    var numberOfTestsCurrentUser: Double = 0
    
    var dataBrainLogInDelegate: dataBrainLogInDelegate?
    var didGetCurrentUser: Bool = false {
        didSet{
            self.dataBrainLogInDelegate?.getCurrentUserOK()
        }
    }
    
    var dataBrainCalendarDelegate: dataBrainCalendarDelegate?
    var calendarCurrentUser: [Bool] = Array(repeating: false, count: 72) {
        didSet{
            self.dataBrainCalendarDelegate?.getCalendar()
        }
    }
    
    
    var dataBrainProgressDelegate : DataBrainProgressDelegate?
    var dateLabelsCurrentUserWorkout: [String] = []
    var firstFitTestCurrentUser: [Double] = []
    var allWorkOutResultsCurrentUser: [Workout] = [] {
        didSet{
            if self.allWorkOutResultsCurrentUser.count == Int(self.numberOfTestsCurrentUser) {
                self.dataBrainProgressDelegate?.updateProgressChart()
            }
        }
    }
    
    var dataPodium: [PodiumCompetitor] = []
    var currentUserMaxValues: [Double] = []
    
    var dataBrainUserMaxValuesDelegate: dataBrainUserMaxValuesDelegate?
    var userMaxValues: [Double] = [] {
        didSet{
            self.dataBrainUserMaxValuesDelegate?.getUserWorkoutInfo()
        }
    }


    func getCurrentUser() {
        self.db.collection(K.FStore.Users.collectionUsersName).document(currentUserID)
            .getDocument { (document, error) in
            if let doc = document {
                if let data = doc.data() {
                    if let pseudo = data[K.FStore.Users.pseudoField] as? String,
                        let avatar = data[K.FStore.Users.avatarField] as? String,
                        let followedUsers = data[K.FStore.Users.followedUsersField] as? [String:String],
                        let calendar = data[K.FStore.Users.calendarField] as? [Bool],
                        let maxValues = data[K.FStore.Users.maxField] as? [Double],
                        let numberOfTests = data[K.FStore.Users.numberOfTestsField] as? Double {
                        
                        self.didGetCurrentUser = true
                        self.currentUserMaxValues = maxValues
                        self.dataFollowedUsers = followedUsers
                        self.pseudoCurrentUser = pseudo
                        self.avatarCurrentUser = avatar
                        self.calendarCurrentUser = calendar
                        self.numberOfTestsCurrentUser = numberOfTests
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
            K.FStore.Users.avatarField: avatarDefault,
            K.FStore.Users.numberOfTestsField: 0
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
                                self.dataPodium.append(podiumCompetitor)
                            }
                        }
                    }
                }
            }
        }
    }

    
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
    
    // MARK: - Methods for Progress View Controller

    func loadWorkoutData() {
        
        db.collection(K.FStore.WorkoutTests.collectionTestName).order(by: K.FStore.WorkoutTests.dateField)
            .whereField(K.FStore.WorkoutTests.idField, isEqualTo: self.currentUserID)
            .getDocuments() { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for (index, doc) in snapshotDocuments.enumerated() {
                        let data = doc.data()
                        if let idCompetitor = data[K.FStore.WorkoutTests.idField] as? String,
                            let testResult = data[K.FStore.WorkoutTests.testField] as? [Double],
                            let testDate = data[K.FStore.WorkoutTests.dateField] as? Timestamp {
                            
                            // get the first fit test for the progression
                            if index == 0 {
                                self.firstFitTestCurrentUser = testResult
                            }
                            
                            let newWorkout = Workout(userID: idCompetitor, workOutResult: testResult, date: testDate)
                            let workOutDate = self.dateString(timeStampDate: newWorkout.date)
                            self.dateLabelsCurrentUserWorkout.append(workOutDate)
                            self.allWorkOutResultsCurrentUser.append(newWorkout)
                        }
                    }
                }
            }
        }
    }
    
    // Func to format the Date of workout Results
    func dateString(timeStampDate: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = timeStampDate.dateValue()
        let dateString = dateFormatter.string(from: date)
        
        return dateString
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
            
            guard let oldNumberOfTests = userDocument.data()?[K.FStore.Users.numberOfTestsField] as? Double else {
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
            transaction.updateData([K.FStore.Users.numberOfTestsField: oldNumberOfTests+1], forDocument: userRef)

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
