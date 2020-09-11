//
//  chartBrain.swift
//  Insanity
//
//  Created by Léa on 29/06/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import Foundation
import Charts


struct ChartBrain {
    
    var barChart: BarChartView
    var allWorkOutResults: [Workout] = []
    var dateLabels: [String] = []
    
    mutating func barChartUpdate(workOutSelected: Int, uid: String) {
        
        var barChartEntry = [ChartDataEntry]()
        if uid == DataBrain.sharedInstance.currentUserID {
            allWorkOutResults = DataBrain.sharedInstance.allWorkOutResultsCurrentUser
            dateLabels = DataBrain.sharedInstance.dateLabelsCurrentUserWorkout
        }
        
        
        for i in 0..<allWorkOutResults.count {
            let value = BarChartDataEntry(x: Double(i), y: allWorkOutResults[i].workOutResult[workOutSelected])
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
        dataSet.highlightEnabled = false
        
        // add "date" Label for X Axis
        barChart.xAxis.labelCount = dateLabels.count
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateLabels)
    
        customizeGraphAppearance(for: barChart, with: data)
        
        barChart.animate(yAxisDuration: 0.5, easingOption: .linear)
        barChart.data = data
    }
    
    mutating func customizeGraphAppearance(for barChart: BarChartView, with data: BarChartData) {
        
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
            data.barWidth = Double(0.50)
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

    
}
