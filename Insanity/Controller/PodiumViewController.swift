//
//  PodiumViewController.swift
//  Insanity
//
//  Created by Léa on 30/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase

class PodiumViewController: UIViewController {
    
    var currentUserID = ""
    
    var workoutSelected = "Switch Kicks"
    let db = Firestore.firestore()
    var dataPodium: [PodiumCompetitor] = []

    @IBOutlet weak var scoreNotOnPodiumLabel: UILabel!
    @IBOutlet weak var textNotOnPodiumLabel: UILabel!
    
    @IBOutlet weak var topOneLabel: UILabel!
    @IBOutlet weak var topTwoLabel: UILabel!
    @IBOutlet weak var topThreeLabel: UILabel!
    
    @IBOutlet weak var topOneImage: UIImageView!
    @IBOutlet weak var topTwoImage: UIImageView!
    @IBOutlet weak var topThreeImage: UIImageView!
    
    @IBOutlet weak var topOnePseudoLabel: UILabel!
    @IBOutlet weak var topTwoPseudoLabel: UILabel!
    @IBOutlet weak var topThreePseudoLabel: UILabel!
    
    @IBOutlet weak var workoutPickerView: UIPickerView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutPickerView.dataSource = self
        workoutPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recupMaxValues()
        defaultPodiumValue()
    }

    func defaultPodiumValue() {
        self.workoutPickerView.selectRow(0, inComponent: 0, animated: false)
        topOneImage.image = UIImage(named: K.userCell.noOpponentAvatar)
        topOneLabel.text = ""
        topOnePseudoLabel.text = "N/A"
        topTwoImage.image = UIImage(named: K.userCell.noOpponentAvatar)
        topTwoLabel.text = ""
        topTwoPseudoLabel.text = "N/A"
        topThreeImage.image = UIImage(named: K.userCell.noOpponentAvatar)
        topThreeLabel.text = ""
        topThreePseudoLabel.text = "N/A"
        scoreNotOnPodiumLabel.text = ""
        textNotOnPodiumLabel.text = ""
    }
    
    
    func recupMaxValues() {
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
                                    print(self.dataPodium)
                                }
                            } // end if let get data
                        } // end for loop
                    } // end if let snapshotdocuments
                } // end of else ... get data
        } // end GetDocuments
    } // end getPodium
    


    func updatePodium(sportRow: Int) {
        // by default, set the comment as if out of Podium
        let currentUserIndex = dataPodium.indices.filter { dataPodium[$0].userID == currentUserID}

        var commentScore = String(format: "%.0f", dataPodium[currentUserIndex[0]].max[sportRow])
        var commentLabel = K.podium.notOnPodium
   
        let dataPodiumFiltered = dataPodium.filter { $0.max.isEmpty == false }

        switch dataPodiumFiltered.count {
        case 1:
            // case only 1 array Max not empty => Data for 1 user
            let index = dataPodium.indices.filter { dataPodium[$0].max == dataPodiumFiltered[0].max } // return array with 1 element
            topOneImage.image = UIImage(named: dataPodium[index[0]].avatar)
            topOneLabel.text = String(format: "%.0f", dataPodium[index[0]].max[sportRow])
            topOnePseudoLabel.text = dataPodium[index[0]].pseudo
            if dataPodium[index[0]].userID == currentUserID {
                commentLabel = K.podium.first
                commentScore = ""
            }
        case 2:
            // case 2 array Max not empty => Data for 2 users
            let maxScore = dataPodiumFiltered.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
            let index = dataPodium.indices.filter { dataPodium[$0].max == maxScore!.max }
            topOneImage.image = UIImage(named: dataPodium[index[0]].avatar)
            topOneLabel.text = String(format: "%.0f", dataPodium[index[0]].max[sportRow])
            topOnePseudoLabel.text = dataPodium[index[0]].pseudo
            if dataPodium[index[0]].userID == currentUserID {
                commentLabel = K.podium.first
                commentScore = ""
            }
            if index.count == 2 {
                topTwoImage.image = UIImage(named: dataPodium[index[1]].avatar)
                topTwoLabel.text = String(format: "%.0f", dataPodium[index[1]].max[sportRow])
                topTwoPseudoLabel.text = dataPodium[index[1]].pseudo
                if dataPodium[index[1]].userID == currentUserID {
                    commentLabel = K.podium.second
                    commentScore = ""
                }
            } else {
                let secondScore = dataPodiumFiltered.filter { $0.max != maxScore!.max }
                let indexSecond = dataPodium.indices.filter { dataPodium[$0].max == secondScore[0].max }
                topTwoImage.image = UIImage(named: dataPodium[indexSecond[0]].avatar)
                topTwoLabel.text = String(format: "%.0f", dataPodium[indexSecond[0]].max[sportRow])
                topTwoPseudoLabel.text = dataPodium[indexSecond[0]].pseudo
                if dataPodium[indexSecond[0]].userID == currentUserID {
                    commentLabel = K.podium.second
                    commentScore = ""
                }
            }
        
        case 3...4:
            // case 3 or more array "Max" not empty => Data for 3 users or more
            let maxScore = dataPodiumFiltered.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
            let index = dataPodium.indices.filter { dataPodium[$0].max == maxScore!.max }
            topOneImage.image = UIImage(named: dataPodium[index[0]].avatar)
            topOneLabel.text = String(format: "%.0f", dataPodium[index[0]].max[sportRow])
            topOnePseudoLabel.text = dataPodium[index[0]].pseudo
            if dataPodium[index[0]].userID == currentUserID {
                commentLabel = K.podium.first
                commentScore = ""
            }
            if index.count == 3 || index.count == 4 {
                // case Ex-aequo between Top 1-2-3-4
                topTwoImage.image = UIImage(named: dataPodium[index[1]].avatar)
                topTwoLabel.text = String(format: "%.0f", dataPodium[index[1]].max[sportRow])
                topTwoPseudoLabel.text = dataPodium[index[1]].pseudo
                topThreeImage.image = UIImage(named: dataPodium[index[2]].avatar)
                topThreeLabel.text = String(format: "%.0f", dataPodium[index[2]].max[sportRow])
                topThreePseudoLabel.text = dataPodium[index[2]].pseudo
                if dataPodium[index[1]].userID == currentUserID {
                    commentLabel = K.podium.second
                    commentScore = ""
                } else if dataPodium[index[2]].userID == currentUserID {
                    commentLabel = K.podium.third
                    commentScore = ""
                } else {
                    if index.count == 4 && dataPodium[index[3]].userID == currentUserID {
                        commentLabel = K.podium.notOnPodium
                        commentScore = String(format: "%.0f", dataPodium[index[3]].max[sportRow])
                    }
                }
            } else if index.count == 2 {
                // case Ex-aequo between Top 1-2
                topTwoImage.image = UIImage(named: dataPodium[index[1]].avatar)
                topTwoLabel.text = String(format: "%.0f", dataPodium[index[1]].max[sportRow])
                topTwoPseudoLabel.text = dataPodium[index[1]].pseudo
                if dataPodium[index[1]].userID == currentUserID {
                    commentLabel = K.podium.second
                    commentScore = ""
                }
            } else {
                // case No Ex-aequo between Top 1-2
                let dataPodiumWithouFirst = dataPodiumFiltered.filter { $0.max != maxScore!.max }
                let SecondMaxScore = dataPodiumWithouFirst.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
                let indexSecond = dataPodium.indices.filter { dataPodium[$0].max == SecondMaxScore!.max }
                topTwoImage.image = UIImage(named: dataPodium[indexSecond[0]].avatar)
                topTwoLabel.text = String(format: "%.0f", dataPodium[indexSecond[0]].max[sportRow])
                topTwoPseudoLabel.text = dataPodium[indexSecond[0]].pseudo
                if dataPodium[indexSecond[0]].userID == currentUserID {
                    commentLabel = K.podium.second
                    commentScore = ""
                }
                if indexSecond.count == 2 || indexSecond.count == 3 {
                    // case, after Top 1, Ex-aequo between Top 2-3-4
                    topThreeImage.image = UIImage(named: dataPodium[indexSecond[1]].avatar)
                    topThreeLabel.text = String(format: "%.0f", dataPodium[indexSecond[1]].max[sportRow])
                    topThreePseudoLabel.text = dataPodium[indexSecond[1]].pseudo
                    if dataPodium[indexSecond[1]].userID == currentUserID {
                        commentLabel = K.podium.third
                        commentScore = ""
                    }
                    if indexSecond.count == 3 && dataPodium[indexSecond[2]].userID == currentUserID{
                        commentLabel = K.podium.notOnPodium
                        commentScore = String(format: "%.0f", dataPodium[indexSecond[2]].max[sportRow])
                    }
                } else {
                    // case No Ex-aequo between Top 1-2-3
                    let dataPodiumThird = dataPodiumWithouFirst.filter { $0.max != SecondMaxScore!.max }
                    let thirdMaxScore = dataPodiumThird.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
                    let indexThird = dataPodium.indices.filter { dataPodium[$0].max == thirdMaxScore!.max }
                    topThreeImage.image = UIImage(named: dataPodium[indexThird[0]].avatar)
                    topThreeLabel.text = String(format: "%.0f", dataPodium[indexThird[0]].max[sportRow])
                    topThreePseudoLabel.text = dataPodium[indexThird[0]].pseudo
                    if dataPodium[indexThird[0]].userID == currentUserID {
                          commentLabel = K.podium.third
                        commentScore = ""
                    }
                }
            }
        default:
            // case if dataPodium contains only empty array => dataPodiumFiltered.count = 0
            print("No data recorded")
        }
        
        textNotOnPodiumLabel.text = commentLabel
        scoreNotOnPodiumLabel.text = commentScore
    }
        
}


// MARK: - UIPickerViewDataSource

extension PodiumViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.workout.workoutMove.count+1
    }
}

// MARK: - UIPickerViewDelegate

extension PodiumViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if row == 0 {
            let attributedString = NSAttributedString(string: "** Please select below **", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            return attributedString
        }
        
        let attributedString = NSAttributedString(string: K.workout.workoutMove[row-1], attributes: [NSAttributedString.Key.foregroundColor : UIColor.label])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if row != 0 {
            updatePodium(sportRow: row-1)
        }
    }
    
}


