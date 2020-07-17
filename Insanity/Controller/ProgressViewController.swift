//
//  ProgressViewController.swift
//  Insanity
//
//  Created by Léa on 24/04/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase
import Charts

class ProgressViewController: UIViewController {
    
    let db = Firestore.firestore()
    var dataWorkoutTest: [Workout] = []
    
    var chartBrain: ChartBrain?
    
    var firstValues: [Double] = []

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment2: UISegmentedControl!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chartBrain = ChartBrain(barChart: barChart)
        
        addTestButton.backgroundColor = .clear
        addTestButton.layer.borderWidth = 1
        addTestButton.layer.borderColor = UIColor.label.cgColor
        addTestButton.layer.cornerRadius = 3
        
        segment1.selectedSegmentIndex = 0
        segment2.selectedSegmentIndex = -1
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

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

        let maxVal = DataBrain.sharedInstance.currentUserMaxValues[workOutSelected]
        let first = firstValues[workOutSelected]
        let percent: Double = ((maxVal - first) / first) * 100
        let percentString = String(format: "%.0f", percent)
        
        let text = "Best progression for \(K.workout.workoutMove[workOutSelected]) since your first fit test"
        
        percentLabel.text = "+"+percentString+"%"
        progressLabel.text = text
    }
    
    // MARK: - Section DataBase Interactions

    func loadWorkoutData() {
        dataWorkoutTest = []

        db.collection(K.FStore.WorkoutTests.collectionTestName).order(by: K.FStore.WorkoutTests.dateField)
            .whereField(K.FStore.WorkoutTests.idField, isEqualTo: DataBrain.sharedInstance.currentUserID)
            .addSnapshotListener { (querySnapshot, error) in
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
                            if let idCompetitor = data[K.FStore.WorkoutTests.idField] as? String,
                                let testResult = data[K.FStore.WorkoutTests.testField] as? [Double],
                                let testDate = data[K.FStore.WorkoutTests.dateField] as? Timestamp {
                                
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
        msgLabel.textColor = .label
    }
    
    func dismissMsg() {
        msgLabel.textColor = .clear
    }
    
    // Func to format the Date of workout Results
    func dateString(timeStampDate: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let date = timeStampDate.dateValue()
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    // MARK: - Add Result Section
    
    @IBAction func addTestPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.segueResultsToTest , sender: self)
    }
    
}
