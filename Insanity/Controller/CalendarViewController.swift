//
//  CalendarViewController.swift
//  Insanity
//
//  Created by Léa on 01/07/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import Firebase

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var calendarIcon: UIButton!
    @IBOutlet weak var tableIcon: UIButton!
    
    let cell = "reuseCell"
    
    let db = Firestore.firestore()
    var currentUserID = ""
        
    let program = [0:"week", 1:"Fit Test", 2:"Plyo Cardio Circuit", 3:"Cardio Power & Resistance", 4:"Cardio Recovery", 5:"Pure Cardio", 6:"Pure Cardio & Abs", 7:"Core Cardio & Balance", 8:"Fit Test / Max Interval Training", 9:"Max Interval Plyo", 10:"Max Cardio Conditioning", 11:"Max Recovery", 12:"Max Interval Circuit", 13:"Max Cardio Conditioning & Abs", 14:"Fit Test/ Max Interval Circuit",15:"Rest"]
        
    let days = ["","Mon", "Tue", "Wed","Thu", "Fri","Sat","Sun"]
    
    let weekNb = [8:"Week 1", 16:"Week 2",24:"Week 3",32:"Week 4",40:"Week 5 Recovery",48:"Week 6",56:"Week 7",64:"Week 8",72:"Week 9"]
        
    private let reuseIdentifier = "calendarCell"
        
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 8,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    )
        
    let workOutCalendar = [0,1,2,3,4,5,2,15,
                        0,3,5,2,4,3,6,15,
                        0,1,2,6,4,3,2,15,
                        0,6,3,2,4,6,2,15,
                        0,7,7,7,7,7,7,15,
                        0,8,9,10,11,12,9,15,
                        0,10,12,9,11,13,7,15,
                        0,14,9,10,11,12,7,15,
                        0,9,13,12,7,9,13,1]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataBrain.sharedInstance.dataBrainCalendarDelegate = self
        currentUserID = DataBrain.sharedInstance.currentUserID
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.register(UINib(nibName: "CalendarTableCell", bundle: nil), forCellReuseIdentifier: "reuseCalendarTableCell")

        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
        
        calendarIcon.tintColor = UIColor(named: K.BrandColor.orangeBrancColor)
        tableIcon.tintColor = .secondaryLabel
        collectionView.alpha = 1
        tableView.alpha = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        updateCalendar()
    }


    func updateCalendar() {
        self.db.collection(K.FStore.Users.collectionUsersName).document(self.currentUserID).updateData([
            K.FStore.Users.calendarField: DataBrain.sharedInstance.calendarCurrentUser
        ]) { error in
            if let err = error {
                print("Error adding document: \(err)")
            }
        }
    }
    
    
    @IBAction func calendarViewTapped(_ sender: UIButton) {
        calendarIcon.tintColor = UIColor(named: K.BrandColor.orangeBrancColor)
        collectionView.alpha = 1
        tableIcon.tintColor = .secondaryLabel
        tableView.alpha = 0
        
    }
    
    @IBAction func tableViewTapped(_ sender: UIButton) {
        tableIcon.tintColor = UIColor(named: K.BrandColor.orangeBrancColor)
        tableView.alpha = 1
        calendarIcon.tintColor = .secondaryLabel
        collectionView.alpha = 0
    }
    
    
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController:  UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workOutCalendar.count + 8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCollectionViewCell

        switch indexPath.item {
        case 0...7:
            // case first line days of week
            cell.calendarCellLabel.text = days[indexPath.item]
            cell.calendarCellLabel.textColor = .label
            cell.backgroundColor = UIColor(named: "barShadowColor")
        case _ where [8,16,24,32,40,48,56,64,72].contains(indexPath.item):
            // case first case of rows for week nb
            cell.calendarCellLabel.text = weekNb[indexPath.item]
            cell.calendarCellLabel.textColor = .label
            cell.backgroundColor = UIColor(named: "barShadowColor")
        default:
            let index = indexPath.item-8
            let workoutNumber = workOutCalendar[index]
            cell.calendarCellLabel.text = program[workoutNumber]
            cell.calendarCellLabel.textColor = .label
            cell.backgroundColor = DataBrain.sharedInstance.calendarCurrentUser[index] ? UIColor(named: K.BrandColor.orangeBrancColor) : .secondarySystemBackground
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.item > 8 && ![8,16,24,32,40,48,56,64,72].contains(indexPath.item) {
            let index = indexPath.item-8
            DataBrain.sharedInstance.calendarCurrentUser[index] = DataBrain.sharedInstance.calendarCurrentUser[index] == false ? true : false
            
            self.collectionView.reloadData()
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension CalendarViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return weekNb.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitleKey = (section+1)*8
        return weekNb[sectionTitleKey]
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count - 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCalendarTableCell", for: indexPath) as! CalendarTableCell

        let section = indexPath.section
        let row = indexPath.row
        
        cell.dayNumber.text = "Day \((section*7) + (row+1))"
        cell.dayOfTheWeek.text = "\(days[row+1])."
        
        let workoutNumber = workOutCalendar[(section*8) + (row+1)]
        cell.workoutLabel.text = program[workoutNumber]

        return cell
    }
    
}

extension CalendarViewController: UITableViewDelegate {
    
}
extension CalendarViewController: dataBrainCalendarDelegate {
    func getCalendar() {
        self.collectionView.reloadData()
    }
}

