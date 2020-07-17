//
//  InfosTableViewController.swift
//  Insanity
//
//  Created by Léa on 17/07/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit

class InfosTableViewController: UITableViewController {
    
    // cell for Contact => click open mailBox associated with user email ?
    // cell for Terms and conditions => open new vc ?
    // cell for Private Policy  => open new vc  ?
    
    var infos = ["Contact", "Terms & Conditions"]
    let cellReuseIdentifier = "cell"

    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.tableFooterView = UIView()

    }

    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infos.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        cell.textLabel?.text = self.infos[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }

}

