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
import SwipeCellKit

class ProgressViewController: UIViewController {
        
    var chartBrain: ChartBrain?
    
    var alert = UIAlertController()
    var alertDeleteTest = UIAlertController()
    var numberTextField = UITextField()
    let forbiddenNumber = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09"]
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var workoutSegment1: UISegmentedControl!
    @IBOutlet weak var workoutSegment2: UISegmentedControl!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var testsTableView: UITableView!
    @IBOutlet weak var typeView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("progress view : view did load called")
        
        DataBrain.sharedInstance.dataBrainProgressDelegate = self
        
        typeView.alpha = 1
        testsTableView.alpha = 0

        chartBrain = ChartBrain(barChart: barChart)
        chartBrain?.barChart.noDataText = ""
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        workoutSegment2.selectedSegmentIndex = -1
        
        if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            workoutSegment1.selectedSegmentIndex = -1
            progressLabel.text = "Let's get started with your first fit test."
            percentLabel.text = "Go!"
        } else {
            workoutSegment1.selectedSegmentIndex = 0
            DataBrain.sharedInstance.loadWorkoutData()
        }
        
        testsTableView.register(UINib(nibName: "TestResultCell", bundle: nil), forCellReuseIdentifier: "reuseTestResultCell")
        numberTextField.delegate = self
    }
    
    

    @IBAction func filterSegmentTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            typeView.alpha = 1
            testsTableView.alpha = 0
        } else {
            typeView.alpha = 0
            testsTableView.alpha = 1
            testsTableView.reloadData()
        }
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        if !DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            var index = 0
            if sender == workoutSegment1 {
                index = workoutSegment1.selectedSegmentIndex
                workoutSegment2.selectedSegmentIndex = -1
            } else if sender == workoutSegment2 {
                index = 4 + workoutSegment2.selectedSegmentIndex
                workoutSegment1.selectedSegmentIndex = -1
            }

            chartBrain?.barChartUpdate(workOutSelected: index, uid: DataBrain.sharedInstance.currentUserID)
            
            if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
                print("no data")
            } else {
                updateProgressForWorkout(workOutSelected: index)
            }
        } else {
            workoutSegment1.selectedSegmentIndex = -1
            workoutSegment2.selectedSegmentIndex = -1
        }
    }
    
    func updateProgressForWorkout(workOutSelected: Int) {

        let maxVal = DataBrain.sharedInstance.currentUserMaxValues[workOutSelected]
        let first = DataBrain.sharedInstance.firstFitTestCurrentUser[workOutSelected]
        let percent: Double = ((maxVal - first) / first) * 100
        let percentString = String(format: "%.0f", percent)
        
        var percentText = ""
        var text = ""
        
        if self.chartBrain?.allWorkOutResults.count == 1 {
            percentText = "Focus!"
            text = "Keep going and you will progress for your next fit test !"
        } else {
            percentText = "+"+percentString+"%"
            text = "Best progression for \(K.workout.workoutMove[workOutSelected]) since your first fit test"
        }

        percentLabel.text = percentText
        progressLabel.text = text
    }

    
    // MARK: - Add Result Section
    
    @IBAction func addTestPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.segueResultsToTest , sender: self)
    }
    
}

    // MARK: - DataBrainProgressDelegate

extension ProgressViewController: DataBrainProgressDelegate {
    func updateProgressChart() {
        print("updateProgressChart called")
        self.testsTableView.dataSource = self
        self.testsTableView.delegate = self
        if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            workoutSegment1.selectedSegmentIndex = -1
            workoutSegment2.selectedSegmentIndex = -1
        } else {
            workoutSegment1.selectedSegmentIndex = 0
            workoutSegment2.selectedSegmentIndex = -1
            let index = self.workoutSegment1.selectedSegmentIndex
            self.updateProgressForWorkout(workOutSelected: index)
            self.chartBrain?.barChartUpdate(workOutSelected: index, uid: DataBrain.sharedInstance.currentUserID)
        }
    }
    
    
}

// MARK: - UITableViewDataSource UITableViewDelegate


extension ProgressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Int(DataBrain.sharedInstance.numberOfTestsCurrentUser)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let frame = tableView.frame

        // create Label for Title
        let rectLabel = CGRect(x: 40, y: 0, width: frame.size.width-30, height: 50)
        let titleLabel = UILabel(frame: rectLabel)
        
        let workoutsTestsSorted =  DataBrain.sharedInstance.allWorkOutResultsCurrentUser.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        let testDate = workoutsTestsSorted[section].date
        
        titleLabel.text = DataBrain.sharedInstance.dateString(timeStampDate: testDate)
        
//        // create Button for trash
//        let rectButton = CGRect(x: frame.size.width-60, y: 13, width: 25, height: 25)
//        let trashButton =  UIButton(frame: rectButton)
//        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
//
//        trashButton.addTarget(self, action: #selector(self.showAlerDeleteTest(_:)), for: .touchUpInside)
//
//        trashButton.tag = section

        // cerate Header View
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        headerView.backgroundColor = .secondarySystemBackground
        headerView.addSubview(titleLabel)
//        headerView.addSubview(trashButton)

        return headerView
    }
    
    
//    @objc func showAlerDeleteTest(_ button:UIButton) {
//
//        let index = button.tag
//
//        let workoutsTestsSorted =  DataBrain.sharedInstance.allWorkOutResultsCurrentUser.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
//        let selectedTestDate = workoutsTestsSorted[index].date
//        let selectedTestDateString = DataBrain.sharedInstance.dateString(timeStampDate: selectedTestDate)
//        let selectedTestID = workoutsTestsSorted[index].workoutID
//
//        // create alert to delete test
//
//        alertDeleteTest = UIAlertController(title: "Delete Test", message: "Do you really want to delete your test from \(selectedTestDateString)?"  , preferredStyle: .alert)
//
//        let action = UIAlertAction(title: "Delete", style: .destructive) { (action) in
//
//            print("delete fit test \(selectedTestID), save changes and reload table view")
//            // update cancel attribut(field) from false to true, + change number of test -1
//
//        }
//
//
//        alertDeleteTest.addAction(action)
//        alertDeleteTest.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        present(alertDeleteTest, animated: true) {
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
//            self.alertDeleteTest.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if DataBrain.sharedInstance.allWorkOutResultsCurrentUser.isEmpty {
            return nil
        } else {
            let workoutsTestsSorted =  DataBrain.sharedInstance.allWorkOutResultsCurrentUser.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            let testDate = workoutsTestsSorted[section].date
            return DataBrain.sharedInstance.dateString(timeStampDate: testDate)
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return K.workout.workoutMove.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseTestResultCell", for: indexPath) as! TestResultCell
        
        cell.delegate = self
        
        let section = indexPath.section
        let row = indexPath.row
        
        let workoutsTestsSorted =  DataBrain.sharedInstance.allWorkOutResultsCurrentUser.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        
        cell.workoutLabel.text = K.workout.workoutMove[row]
        cell.workoutScore.text = String(format: "%.0f",workoutsTestsSorted[section].workOutResult[row])

        return cell
    }
    

}

// MARK: - SwipeTableViewCellDelegate


extension ProgressViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let section = indexPath.section
        let row = indexPath.row
        
        let workoutsTestsSorted =  DataBrain.sharedInstance.allWorkOutResultsCurrentUser.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        
        let testDocID = workoutsTestsSorted[section].workoutID
        let testDate = workoutsTestsSorted[section].date
        let exoDate = DataBrain.sharedInstance.dateString(timeStampDate: testDate)
        let exoName = K.workout.workoutMove[row]
        let exoScore = String(format: "%.0f",workoutsTestsSorted[section].workOutResult[row])
        
        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
                        
            self.showEditAlert(docID: testDocID, exoRowNumber: row, section: section, exo: exoName, date: exoDate, number: exoScore)
        }

        // customize the action appearance
        editAction.backgroundColor = UIColor(named: K.BrandColor.orangeBrancColor)

        return [editAction]
    }

    
    private func showEditAlert(docID: String, exoRowNumber: Int, section: Int, exo: String, date: String, number: String) {
        
        alert = UIAlertController(title: "Edit", message: "\(exo) from \(date)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            if self.numberTextField.text == "" {
                // close alert with no update
                print("no change")
            } else {

                let index = DataBrain.sharedInstance.allWorkOutResultsCurrentUser.indices.filter { DataBrain.sharedInstance.allWorkOutResultsCurrentUser[$0].workoutID == docID } // return array with 1 element
                
                let oldValue = DataBrain.sharedInstance.allWorkOutResultsCurrentUser[index[0]].workOutResult[exoRowNumber]
                print(oldValue)
                let newValue = Double(self.numberTextField.text!)!
                DataBrain.sharedInstance.allWorkOutResultsCurrentUser[index[0]].workOutResult[exoRowNumber] = newValue
                let workOutResultUpdated = DataBrain.sharedInstance.allWorkOutResultsCurrentUser[index[0]].workOutResult
                
                // update all workout data + Max workout
                DataBrain.sharedInstance.changevalueInTestResult(docID: docID, workoutresultModify: workOutResultUpdated)
                DataBrain.sharedInstance.majMaxAfterValueUpdated(oldValue: oldValue, newValue: newValue, exoNumber: exoRowNumber)
                
                // update table view
                self.testsTableView.reloadSections([section], with: .none)

            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.delegate = self
            alertTextField.placeholder = number
            self.numberTextField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            self.alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }

    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate


extension ProgressViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        //Prevent "0" characters to be followed by other number
        if forbiddenNumber.contains(text) {
            return false
        }
        //Limit the character count to 3.
        if ((textField.text!) + string).count > 3 {
            return false
        }
        //Only allow numbers. No Copy-Paste text values.
        let allowedCharacterSet = CharacterSet.init(charactersIn: "0123456789")
        let textCharacterSet = CharacterSet.init(charactersIn: textField.text! + string)
        if !allowedCharacterSet.isSuperset(of: textCharacterSet) {
            return false
        }
        return true
    }
}
