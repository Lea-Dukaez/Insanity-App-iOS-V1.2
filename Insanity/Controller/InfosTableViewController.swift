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

    let alert = UIAlertController(title: "Mail App Not Install", message: "For any feature request or bug report, please contact us at: lea.s.dkz+insanity@gmail.com", preferredStyle: UIAlertController.Style.alert)
    
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
        
        let recipientEmail = "lea.s.dkz+insanity@gmail.com"
        let subject = "Feedback Insanitiy Progress Tracking"
        let body = "Feature request or bug report"

        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)

            present(mail, animated: true)

        // Show third party email composer if default Mail app is not present
        } else {
            showAlert()
        }

    }
    
    func showAlert() {
        self.present(alert, animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert))
            self.alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
