//
//  FriendActivityViewController.swift
//  Insanity
//
//  Created by Léa on 29/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase
import Charts

class FriendActivityViewController: UIViewController {
    
    let db = Firestore.firestore()
    var dataWorkoutTest: [Workout] = []
    
    var chartBrain: ChartBrain?
    var dataBrain = DataBrain()
    
    var friendAvatar = ""
    var friendPseudo = ""
    var friendID: String = ""
    
    var firstValues: [Double] = []

    
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var friendPseudoLabel: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment2: UISegmentedControl!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendImage.image = UIImage(named: friendAvatar)
        friendPseudoLabel.text = friendPseudo
        
        chartBrain = ChartBrain(barChart: barChart)
        
        segment1.selectedSegmentIndex = 0
        segment2.selectedSegmentIndex = -1
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        dataBrain.recupUserMax(uid: friendID)
        loadWorkoutData()
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        var index = 0
        if sender == segment1 {
            index = segment1.selectedSegmentIndex
            segment2.selectedSegmentIndex = -1
        } else if sender == segment2 {
            index = 4 + segment2.selectedSegmentIndex
            segment1.selectedSegmentIndex = -1
        }

        chartBrain?.barChartUpdate(workOutSelected: index)
        updateProgressForWorkout(workOutSelected: index)
    }
    
    func updateProgressForWorkout(workOutSelected: Int) {
        print(workOutSelected)
        print()
        let maxVal = dataBrain.userMaxValues[workOutSelected]
        let first = firstValues[workOutSelected]
        let percent: Double = ((maxVal - first) / first) * 100
        let percentString = String(format: "%.0f", percent)
        
        let text = "Best progression for \(K.workout.workoutMove[workOutSelected]) since the first fit test"
        
        percentLabel.text = "+"+percentString+"%"
        progressLabel.text = text
    }
    
    // MARK: - Get Data from DB

    func loadWorkoutData() {
        dataWorkoutTest = []

        db.collection(K.FStore.collectionTestName).order(by: K.FStore.dateField)
            .whereField(K.FStore.idField, isEqualTo: self.friendID)
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
                        for (index, doc) in snapshotDocuments.enumerated() {
                            let data = doc.data()
                            if let idCompetitor = data[K.FStore.idField] as? String, let testResult = data[K.FStore.testField] as? [Double], let testDate = data[K.FStore.dateField] as? Timestamp {
                                
                                // get the first fit test for the progression
                                if index == 0 {
                                    self.firstValues = testResult
                                }
                                
                                let newWorkout = Workout(userID: idCompetitor, workOutResult: testResult, date: testDate)
                                self.chartBrain?.allWorkOutResults.append(newWorkout)
                                let workOutDate = self.dateString(timeStampDate: newWorkout.date)
                                self.chartBrain?.dateLabels.append(workOutDate)
                                
                                // when data is collected, generate barChart
                                DispatchQueue.main.async {
                                    let index = self.segment1.selectedSegmentIndex
                                    self.updateProgressForWorkout(workOutSelected: index)
                                    self.chartBrain?.barChartUpdate(workOutSelected: index)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // Func for Alert if No data recorder
    func showMsg() {
        noDataLabel.textColor = .label
    }
    
    func dismissMsg() {
        noDataLabel.textColor = .clear
    }
    
    // Func to format the Date of workout Results
    func dateString(timeStampDate: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = timeStampDate.dateValue()
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }

}
