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
        
    var chartBrain: ChartBrain?
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var addTestButton: UIButton!
    @IBOutlet weak var segment1: UISegmentedControl!
    @IBOutlet weak var segment2: UISegmentedControl!
    @IBOutlet weak var barChart: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataBrain.sharedInstance.dataBrainProgressDelegate = self

        chartBrain = ChartBrain(barChart: barChart)
        chartBrain?.barChart.noDataText = ""
        
        addTestButton.backgroundColor = .clear
        addTestButton.layer.borderWidth = 1
        addTestButton.layer.borderColor = UIColor.label.cgColor
        addTestButton.layer.cornerRadius = 3
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        segment2.selectedSegmentIndex = -1
        
        if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            segment1.selectedSegmentIndex = -1
            progressLabel.text = "Let's get started with your first fit test."
            percentLabel.text = "Go!"
        } else {
            segment1.selectedSegmentIndex = 0
            DataBrain.sharedInstance.loadWorkoutData()
        }
    }

    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        if !DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            var index = 0
            if sender == segment1 {
                index = segment1.selectedSegmentIndex
                segment2.selectedSegmentIndex = -1
            } else if sender == segment2 {
                index = 4 + segment2.selectedSegmentIndex
                segment1.selectedSegmentIndex = -1
            }

            chartBrain?.barChartUpdate(workOutSelected: index, uid: DataBrain.sharedInstance.currentUserID)
            
            if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
                print("no data recorded, so no progression")
            } else {
                updateProgressForWorkout(workOutSelected: index)
            }
        } else {
            segment1.selectedSegmentIndex = -1
            segment2.selectedSegmentIndex = -1
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

extension ProgressViewController: DataBrainProgressDelegate {
    func updateProgressChart() {
        if DataBrain.sharedInstance.currentUserMaxValues.isEmpty {
            segment1.selectedSegmentIndex = -1
            segment2.selectedSegmentIndex = -1
        } else {
            segment1.selectedSegmentIndex = 0
            segment2.selectedSegmentIndex = -1
            let index = self.segment1.selectedSegmentIndex
            self.updateProgressForWorkout(workOutSelected: index)
            self.chartBrain?.barChartUpdate(workOutSelected: index, uid: DataBrain.sharedInstance.currentUserID)
        }
    }
    
    
}
