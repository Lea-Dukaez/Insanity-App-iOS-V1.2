//
//  InfosTableViewController.swift
//  Insanity
//
//  Created by Léa on 17/07/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//

import UIKit
import MessageUI

class InfosTableViewController: UITableViewController {
    
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
        if self.infos[indexPath.row] == "Terms & Conditions" {
            performSegue(withIdentifier: K.Segue.segueInfoGoToTerms, sender: self)
        } else if self.infos[indexPath.row] == "Contact"{
            self.openEmail()
        }

    }

}

extension InfosTableViewController: MFMailComposeViewControllerDelegate {
    func openEmail() {

        // Use the iOS Mail app
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["lea.s.dkz+insanity@gmail.com"])
        composeVC.setSubject("Feedback")
        composeVC.setMessageBody("Feature request or bug report?", isHTML: false)

        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }

    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
