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
    
    var currentUserID: String = ""
    var workoutSelected = "Switch Kicks"
    
    private var commentScore = ""
    private var commentLabel = ""

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

        currentUserID = DataBrain.sharedInstance.currentUserID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DataBrain.sharedInstance.recupPodiumMaxValues()
        workoutPickerView.dataSource = self
        workoutPickerView.delegate = self
        defaultPodiumValue()
    }

    func defaultPodiumValue() {
        self.workoutPickerView.selectRow(0, inComponent: 0, animated: false)
        topOneImage.image = UIImage()
        topOneLabel.text = ""
        topOnePseudoLabel.text = ""
        topTwoImage.image = UIImage()
        topTwoLabel.text = ""
        topTwoPseudoLabel.text = ""
        topThreeImage.image = UIImage()
        topThreeLabel.text = ""
        topThreePseudoLabel.text = ""
        scoreNotOnPodiumLabel.text = ""
        textNotOnPodiumLabel.text = ""
    }
    

    func updatePodium(sportRow: Int) {
        
        // get an array containing the index of current user
        let arrayCurrentUser = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].userID == currentUserID}
        let indexCurrentUser = arrayCurrentUser[0]
                
        if DataBrain.sharedInstance.dataPodium[indexCurrentUser].max.count == 0 {
            // case no score recorded for current user
            commentScore = ""
            commentLabel = "Let's get started with your first fit test to compare yourself with your followed friends."
        } else {
            // case by default, current user out of Podium
            commentScore = String(format: "%.0f", DataBrain.sharedInstance.dataPodium[indexCurrentUser].max[sportRow])
            commentLabel = K.podium.notOnPodium
        }
        
        let dataPodiumFiltered = DataBrain.sharedInstance.dataPodium.filter { $0.max.isEmpty == false }
        let nbUsersData = dataPodiumFiltered.count
        
                
        if nbUsersData == 1 {
            // case only 1 array Max not empty => Data for 1 user
            let arrayFirstUser = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == dataPodiumFiltered[0].max } // return array with 1 element
            
            updateUIFirst(arrayFirstUser: arrayFirstUser, workout: sportRow, nbUsersData: nbUsersData)
            
        } else if nbUsersData == 2 {
            // case 2 array Max not empty => Data for 2 users
            let maxScore = dataPodiumFiltered.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
            let arrayFirstUser = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == maxScore!.max }
            
            updateUIFirst(arrayFirstUser: arrayFirstUser, workout: sportRow, nbUsersData: nbUsersData)
            
            if arrayFirstUser.count == 2 {
                let index = arrayFirstUser[1]
                updateUISecond(indexSecond: index, workout: sportRow)
        
            } else {
                let secondScore = dataPodiumFiltered.filter { $0.max != maxScore!.max }
                let arrayIndexSecond = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == secondScore[0].max }
                
                let index = arrayIndexSecond[0]
                updateUISecond(indexSecond: index, workout: sportRow)
            }
        
        } else if nbUsersData >= 3 {
            // case 3 or more array "Max" not empty => Data for 3 users or more
            let maxScore = dataPodiumFiltered.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
            let arrayFirstUser = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == maxScore!.max }
            
            updateUIFirst(arrayFirstUser: arrayFirstUser, workout: sportRow, nbUsersData: nbUsersData)

            if arrayFirstUser.count >= 3 { //  == 3 || arrayFirstUser.count == 4
                // case Ex-aequo between Top 1-2-3-4 ...
                
                let indexSecond = arrayFirstUser[1]
                updateUISecond(indexSecond: indexSecond, workout: sportRow)
            
                let indexThird = arrayFirstUser[2]
                updateUIThird(indexThird: indexThird, workout: sportRow)
                
                updateUINotOnPodium(arrayFirstUser[0], indexSecond, indexThird, indexCurrentUser, workout: sportRow)

                
            } else if arrayFirstUser.count == 2 {
                // case Ex-aequo between Top 1-2
                
                let indexSecond = arrayFirstUser[1]
                updateUISecond(indexSecond: indexSecond, workout: sportRow)
                
                let thirdScore = dataPodiumFiltered.filter { $0.max != maxScore!.max }
                let arrayIndexThird = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == thirdScore[0].max }
                let indexThird = arrayIndexThird[0]
                updateUIThird(indexThird: indexThird, workout: sportRow)
                
                updateUINotOnPodium(arrayFirstUser[0], indexSecond, indexThird, indexCurrentUser, workout: sportRow)
                
            } else {
                // case No Ex-aequo for first place

                let dataPodiumWithouFirst = dataPodiumFiltered.filter { $0.max != maxScore!.max }
                let SecondMaxScore = dataPodiumWithouFirst.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
                let arrayIndexSecond = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == SecondMaxScore!.max }
                let indexSecond = arrayIndexSecond[0]
                updateUISecond(indexSecond: indexSecond, workout: sportRow)

                if arrayIndexSecond.count >= 2 { //  == 2 || arrayIndexSecond.count == 3 {
                    // case, after Top 1, Ex-aequo between Top 2-3-4
                    
                    let indexThird = arrayIndexSecond[1]
                    updateUIThird(indexThird: indexThird, workout: sportRow)
                    
                    updateUINotOnPodium(arrayFirstUser[0], indexSecond, indexThird, indexCurrentUser, workout: sportRow)
                    
                } else {
                    // case No Ex-aequo anywhere

                    let dataPodiumThird = dataPodiumWithouFirst.filter { $0.max != SecondMaxScore!.max }
                    let thirdMaxScore = dataPodiumThird.max { user1, user2  in user1.max[sportRow] < user2.max[sportRow] }
                    let arrayIndexThird = DataBrain.sharedInstance.dataPodium.indices.filter { DataBrain.sharedInstance.dataPodium[$0].max == thirdMaxScore!.max }
                    
                    let indexThird = arrayIndexThird[0]
                    updateUIThird(indexThird: indexThird, workout: sportRow)
                    
                    updateUINotOnPodium(arrayFirstUser[0], indexSecond, indexThird, indexCurrentUser, workout: sportRow)
                    
                }
            }
        }

        textNotOnPodiumLabel.text = commentLabel
        scoreNotOnPodiumLabel.text = commentScore
    }
    
    
    private func updateUIFirst(arrayFirstUser: [Range<Array<PodiumCompetitor>.Index>.Element], workout: Int, nbUsersData: Int) {
        let indexFirst = arrayFirstUser[0]
        
        self.topOneImage.image = UIImage(named: DataBrain.sharedInstance.dataPodium[indexFirst].avatar)
        self.topOneLabel.text = String(format: "%.0f", DataBrain.sharedInstance.dataPodium[indexFirst].max[workout])
        self.topOnePseudoLabel.text = DataBrain.sharedInstance.dataPodium[indexFirst].pseudo
        
        if DataBrain.sharedInstance.dataPodium[indexFirst].userID == currentUserID && nbUsersData == 1 {
            commentLabel = DataBrain.sharedInstance.dataPodium.count == 1 ? K.podium.firstNoFriend : K.podium.firstNoDataForFriends
            commentScore = ""
        } else {
            commentLabel = K.podium.first
            commentScore = ""
        }
    }
    
    private func updateUISecond(indexSecond: Range<Array<PodiumCompetitor>.Index>.Element, workout: Int) {
        topTwoImage.image = UIImage(named: DataBrain.sharedInstance.dataPodium[indexSecond].avatar)
        topTwoLabel.text = String(format: "%.0f", DataBrain.sharedInstance.dataPodium[indexSecond].max[workout])
        topTwoPseudoLabel.text = DataBrain.sharedInstance.dataPodium[indexSecond].pseudo
        
        if DataBrain.sharedInstance.dataPodium[indexSecond].userID == currentUserID {
            commentLabel = K.podium.second
            commentScore = ""
        }
    }
    
    private func updateUIThird(indexThird: Range<Array<PodiumCompetitor>.Index>.Element, workout: Int) {
        topThreeImage.image = UIImage(named: DataBrain.sharedInstance.dataPodium[indexThird].avatar)
        topThreeLabel.text = String(format: "%.0f", DataBrain.sharedInstance.dataPodium[indexThird].max[workout])
        topThreePseudoLabel.text = DataBrain.sharedInstance.dataPodium[indexThird].pseudo
        
        if DataBrain.sharedInstance.dataPodium[indexThird].userID == currentUserID {
            commentLabel = K.podium.third
            commentScore = ""
        }
    }
    
    private func updateUINotOnPodium(_ indexFirst: Range<Array<PodiumCompetitor>.Index>.Element, _ indexSecond: Range<Array<PodiumCompetitor>.Index>.Element, _ indexThird: Range<Array<PodiumCompetitor>.Index>.Element, _ indexCurrentUser: Range<Array<PodiumCompetitor>.Index>.Element, workout: Int) {
        
        if DataBrain.sharedInstance.dataPodium[indexFirst].userID != currentUserID &&
            DataBrain.sharedInstance.dataPodium[indexSecond].userID != currentUserID &&
            DataBrain.sharedInstance.dataPodium[indexThird].userID != currentUserID
        {
            commentLabel = K.podium.notOnPodium
            commentScore = String(format: "%.0f", DataBrain.sharedInstance.dataPodium[indexCurrentUser].max[workout])
        }
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
        if row == 0 {
            defaultPodiumValue()
        } else {
            updatePodium(sportRow: row-1)
        }
    }
    
}


