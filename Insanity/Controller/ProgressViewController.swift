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
    
    var allWorkOutResults: [Workout] = []
    var dateLabels: [String] = []
    
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

        addTestButton.backgroundColor = .clear
        addTestButton.layer.borderWidth = 1
        addTestButton.layer.borderColor = UIColor.label.cgColor
        
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
        print(index)
        barChartUpdate(workOutNb: index)
    }
    
    // MARK: - Get Data from DB

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
                                self.allWorkOutResults.append(newWorkout)
                                
                                let workOutDate = self.dateString(timeStampDate: newWorkout.date)
                                self.dateLabels.append(workOutDate)

                                // when data is collected, generate barChart
                                DispatchQueue.main.async {
                                    self.barChartUpdate(workOutNb: self.segment1.selectedSegmentIndex)
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
    
    
    // MARK: - Bar Chart renderer
    
    func barChartUpdate(workOutNb: Int) {
        var barChartEntry = [ChartDataEntry]()
        
        for i in 0..<allWorkOutResults.count {
            let value = BarChartDataEntry(x: Double(i), y: allWorkOutResults[i].workOutResult[workOutNb])
            barChartEntry.append(value)
        }
        
        let dataSet = BarChartDataSet(entries: barChartEntry)
        let data = BarChartData(dataSets: [dataSet])
        
        // formatter so that value for label have no decimal
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        data.setValueFormatter(formatter)

        dataSet.barShadowColor = UIColor(named: "barShadowColor")!
        dataSet.setColor(UIColor(named: "BrandOrangeColor")!)
        
        // add "date" Label for X Axis
        barChart.xAxis.labelCount = dateLabels.count
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
    
        customizeGraphAppearance(for: barChart, with: data)
        
        barChart.animate(yAxisDuration: 0.5, easingOption: .linear)
        barChart.data = data
    }
    
    func customizeGraphAppearance(for barChart: BarChartView, with data: BarChartData) {
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
        
        barChart.legend.enabled = false
        barChart.drawBarShadowEnabled = true

        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChart.xAxis.drawAxisLineEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        
        barChart.leftAxis.axisMinimum = 0
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
    }

    
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
    
    

    

    
    // MARK: - Add Result Section
    
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
