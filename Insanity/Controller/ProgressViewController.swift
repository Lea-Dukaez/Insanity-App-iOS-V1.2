//
//  ProgressViewController.swift
//  Insanity
//
//  Created by Léa on 24/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase

class ProgressViewController: UIViewController {
        
    let db = Firestore.firestore()
    
    var dataWorkoutTest: [Workout] = []
        
    var userName = ""
    var avatarImg = ""
    var uid = ""

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var addTestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Progress View Did Load")

        addTestButton.backgroundColor = .clear
        addTestButton.layer.borderWidth = 1
        addTestButton.layer.borderColor = UIColor.label.cgColor

        loadWorkoutData()
    }
    

    func loadWorkoutData() {
        dataWorkoutTest = []
        
        db.collection(K.FStore.collectionTestName).order(by: K.FStore.dateField)
            .whereField(K.FStore.idField, isEqualTo: self.uid)
            .getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.isEmpty {
                    self.showMsg()
                } else {
                    self.dismissMsg()
                    // documents exist in Firestore
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let idCompetitor = data[K.FStore.idField] as? String, let testResult = data[K.FStore.testField] as? [Double], let testDate = data[K.FStore.dateField] as? Timestamp {
                                let newWorkout = Workout(userID: idCompetitor, workOutResult: testResult, date: testDate)
                                self.dataWorkoutTest.append(newWorkout)
                                
                                // when data is collected, create the tableview
                                DispatchQueue.main.async {
                                    self.tableView.dataSource = self
                                    self.tableView.register(UINib(nibName: K.workout.workoutCellNibName, bundle: nil), forCellReuseIdentifier: K.workout.workoutCellIdentifier)
                                    self.tableView.reloadData()
                                } // fin dispatchQueue
                            }
                        }
                    } // fin if let snapshotDoc
                }
            } // fin else no error ...so access data possible
        } // fin getDocument
    } // fonction loadData()
    
    
    func Percent(old: Double, new: Double, cellForPercent: WorkoutCell) -> String {
        let percent: Double = ((new - old) / old) * 100
        let percentString = String(format: "%.0f", percent)
        
        if percent>=0 {
            cellForPercent.test5Label.textColor = .green
            return "+"+percentString+"%"
        } else {
            cellForPercent.test5Label.textColor = .red
            return percentString+"%"
        }
    }
    
    
    func dateString(timeStampDate: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = timeStampDate.dateValue()
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func showMsg() {
        msgLabel.textColor = .white
    }
    
    func dismissMsg() {
        msgLabel.textColor = .clear
    }
    
    @IBAction func addTestPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.segueResultsToTest, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueResultsToTest {
            let testView = segue.destination as! TestViewController
            testView.userName = userName
            testView.avatarImg = avatarImg
            testView.currentUserId = uid
        }
    }
    
    
}

// MARK: - UITableViewDataSource

extension ProgressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return K.workout.workoutMove.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.workout.workoutCellIdentifier, for: indexPath) as! WorkoutCell
        
        let cellTestLabelArray = [cell.test1Label, cell.test2Label, cell.test3Label, cell.test4Label, cell.test5Label]
        
//        let nbWorkoutTest = dataWorkoutTest.count
        
        switch dataWorkoutTest.count {
        case 1:
            if indexPath.row == 0 {
                cell.workoutMoveLabel.text = ""
                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
            } else {
                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
            }
            for index in 1...4 {
                cellTestLabelArray[index]?.text = ""
            }
        case 2:
            if indexPath.row == 0 {
                cell.workoutMoveLabel.text = ""
                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
                cell.test2Label.text = dateString(timeStampDate: dataWorkoutTest[1].date)
            } else {
                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
                cell.test2Label.text = String(format: "%.0f", dataWorkoutTest[1].workOutResult[indexPath.row-1])
            }
            for index in 2...4 {
                cellTestLabelArray[index]?.text = ""
            }
        case 3:
            if indexPath.row == 0 {
                cell.workoutMoveLabel.text = ""
                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
                cell.test2Label.text = dateString(timeStampDate: dataWorkoutTest[1].date)
                cell.test3Label.text = dateString(timeStampDate: dataWorkoutTest[2].date)
            } else {
                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
                cell.test2Label.text = String(format: "%.0f", dataWorkoutTest[1].workOutResult[indexPath.row-1])
                cell.test3Label.text = String(format: "%.0f", dataWorkoutTest[2].workOutResult[indexPath.row-1])
            }
            for index in 3...4 {
                cellTestLabelArray[index]?.text = ""
            }
        case 4:
            if indexPath.row == 0 {
                cell.workoutMoveLabel.text = ""
                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
                cell.test2Label.text = dateString(timeStampDate: dataWorkoutTest[1].date)
                cell.test3Label.text = dateString(timeStampDate: dataWorkoutTest[2].date)
                cell.test4Label.text = dateString(timeStampDate: dataWorkoutTest[3].date)
                cell.test5Label.text = ""
            } else {
                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
                cell.test2Label.text = String(format: "%.0f", dataWorkoutTest[1].workOutResult[indexPath.row-1])
                cell.test3Label.text = String(format: "%.0f", dataWorkoutTest[2].workOutResult[indexPath.row-1])
                cell.test4Label.text = String(format: "%.0f", dataWorkoutTest[3].workOutResult[indexPath.row-1])
                cell.test5Label.text = ""
            }
        default:
            if indexPath.row == 0 {
                cell.workoutMoveLabel.text = ""
                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
                cell.test2Label.text = dateString(timeStampDate: dataWorkoutTest[1].date)
                cell.test3Label.text = dateString(timeStampDate: dataWorkoutTest[2].date)
                cell.test4Label.text = dateString(timeStampDate: dataWorkoutTest[3].date)
                cell.test5Label.text = dateString(timeStampDate: dataWorkoutTest[4].date)
            } else {
                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
                cell.test2Label.text = String(format: "%.0f", dataWorkoutTest[1].workOutResult[indexPath.row-1])
                cell.test3Label.text = String(format: "%.0f", dataWorkoutTest[2].workOutResult[indexPath.row-1])
                cell.test4Label.text = String(format: "%.0f", dataWorkoutTest[3].workOutResult[indexPath.row-1])
                cell.test5Label.text = String(format: "%.0f", dataWorkoutTest[4].workOutResult[indexPath.row-1])
            }
        }
        
//        // cas particulier seulement : 1 test fait par le user
//        if dataWorkoutTest.count == 1 {
//            if indexPath.row == 0 {
//                cell.workoutMoveLabel.text = ""
//                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
//                cell.test2Label.text = "N/A"
//                cell.test3Label.text = "N/A"
//                cell.test4Label.text = "N/A"
//                cell.test5Label.text = "N/A"
//            } else {
//                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
//                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
//                cell.test2Label.text = "N/A"
//                cell.test3Label.text = "N/A"
//                cell.test4Label.text = "N/A"
//                cell.test5Label.text = "N/A"
//                cell.test2Label.textColor = UIColor(named: K.BrandColor.greenBrandColor)
//                cell.test5Label.textColor = UIColor(named: K.BrandColor.greenBrandColor)
//            }
//        } else {
//            if indexPath.row == 0 {
//                cell.workoutMoveLabel.text = ""
//                cell.test1Label.text = dateString(timeStampDate: dataWorkoutTest[1].date)
//                cell.test2Label.text = dateString(timeStampDate: dataWorkoutTest[0].date)
//                cell.test5Label.text = "%"
//            } else {
//                cell.workoutMoveLabel.text = K.workout.workoutMove[indexPath.row-1]
//                cell.test1Label.text = String(format: "%.0f", dataWorkoutTest[1].workOutResult[indexPath.row-1])
//                cell.test2Label.text = String(format: "%.0f", dataWorkoutTest[0].workOutResult[indexPath.row-1])
//                cell.test5Label.text = Percent(old: dataWorkoutTest[1].workOutResult[indexPath.row-1], new: dataWorkoutTest[0].workOutResult[indexPath.row-1], cellForPercent: cell)
//            }
//        }

        return cell
    }
}
 
