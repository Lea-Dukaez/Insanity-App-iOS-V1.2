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

    let allWorkOutResults: [Workout] = [
        Workout(userID: "1", workOutResult: [56, 48, 25, 68, 12, 40, 15, 59]),
        Workout(userID: "1", workOutResult: [59, 42, 28, 83, 13, 45, 17, 70]),
        Workout(userID: "1", workOutResult: [60, 53, 31, 73, 15, 67, 21, 71]),
        Workout(userID: "1", workOutResult: [60, 59, 29, 80, 17, 66, 23, 80])
    ]
    
    let months = ["Mar", "Apr", "May", "Jun", "Jul"]

        
    var userName = ""
    var avatarImg = ""
    var uid = ""

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment2: UISegmentedControl!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Progress View Did Load")

        addTestButton.backgroundColor = .clear
        addTestButton.layer.borderWidth = 1
        addTestButton.layer.borderColor = UIColor.label.cgColor
        
        segment1.selectedSegmentIndex = 0
        segment2.selectedSegmentIndex = -1

        barChartUpdate(workOutNb: segment1.selectedSegmentIndex)

//        loadWorkoutData()
    }
    
    func barChartUpdate(workOutNb: Int) {
        var min: Double = 0
        var max: Double = 100

        var barChartEntry = [ChartDataEntry]()
        for i in 0..<allWorkOutResults.count {
            let value = BarChartDataEntry(x: Double(i+1), y: allWorkOutResults[i].workOutResult[workOutNb])
            barChartEntry.append(value)

            if i == 0 {
                min = allWorkOutResults[i].workOutResult[workOutNb]
                max = allWorkOutResults[i].workOutResult[workOutNb]
            } else {
                if allWorkOutResults[i].workOutResult[workOutNb] < min {
                    min = allWorkOutResults[i].workOutResult[workOutNb]
                } else if allWorkOutResults[i].workOutResult[workOutNb] > max {
                    max = allWorkOutResults[i].workOutResult[workOutNb]
                }
            }
        }

        
        let dataSet = BarChartDataSet(entries: barChartEntry)
        let data = BarChartData(dataSets: [dataSet])
        
        switch allWorkOutResults.count {
        case 1:
            data.barWidth = Double(0.08)
        case 2:
            data.barWidth = Double(0.16)
        case 3:
            data.barWidth = Double(0.24)
        case 4:
            data.barWidth = Double(0.32)
        case 5:
            data.barWidth = Double(0.40)
        default:
            data.barWidth = Double(0.24)
        }


        dataSet.barShadowColor = UIColor(named: "barShadowColor")!
        
        barChart.legend.enabled = false
        barChart.drawBarShadowEnabled = true

        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChart.xAxis.drawAxisLineEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.axisMinimum = min - 5
        barChart.leftAxis.axisMaximum = max + 5
        
        

        barChart.rightAxis.removeAllLimitLines()
        barChart.rightAxis.drawZeroLineEnabled = false
        barChart.leftAxis.zeroLineWidth = 0
        barChart.rightAxis.drawTopYLabelEntryEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.drawLimitLinesBehindDataEnabled = false

        barChart.animate(yAxisDuration: 0.5, easingOption: .linear)
        
        barChart.data = data
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        var index = 0
        if sender == segment1 {
            index = segment1.selectedSegmentIndex
            segment2.selectedSegmentIndex = -1
        } else if sender == segment2 {
            index = segment2.selectedSegmentIndex
            segment1.selectedSegmentIndex = -1
        }
        barChartUpdate(workOutNb: index)
    }
    

//
//
//    func loadWorkoutData() {
//        dataWorkoutTest = []
//
//        db.collection(K.FStore.collectionTestName).order(by: K.FStore.dateField)
//            .whereField(K.FStore.idField, isEqualTo: self.uid)
//            .getDocuments { (querySnapshot, error) in
//            if let err = error {
//                print("Error getting documents: \(err)")
//            } else {
//                if querySnapshot!.isEmpty {
//                    self.showMsg()
//                } else {
//                    self.dismissMsg()
//                    // documents exist in Firestore
//                    if let snapshotDocuments = querySnapshot?.documents {
//                        for doc in snapshotDocuments {
//                            let data = doc.data()
//                            if let idCompetitor = data[K.FStore.idField] as? String, let testResult = data[K.FStore.testField] as? [Double], let testDate = data[K.FStore.dateField] as? Timestamp {
//                                let newWorkout = Workout(userID: idCompetitor, workOutResult: testResult, date: testDate)
//                                self.dataWorkoutTest.append(newWorkout)
//
//                                // when data is collected, create the tableview
//                                DispatchQueue.main.async {
//                                    self.tableView.dataSource = self
//                                    self.tableView.register(UINib(nibName: K.workout.workoutCellNibName, bundle: nil), forCellReuseIdentifier: K.workout.workoutCellIdentifier)
//                                    self.tableView.reloadData()
//                                } // fin dispatchQueue
//                            }
//                        }
//                    } // fin if let snapshotDoc
//                }
//            } // fin else no error ...so access data possible
//        } // fin getDocument
//    } // fonction loadData()
//
    
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
            testView.currentUserId = uid
        }
    }
    
    
}
