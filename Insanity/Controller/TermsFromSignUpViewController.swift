//
//  TermsFromSignUpViewController.swift
//  Insanity
//
//  Created by Léa on 20/07/2020.
//  Copyright © 2020 Lea Dukaez. All rights reserved.
//


import UIKit
import WebKit
import Firebase

class TermsFromSignUpViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    let urlString = "https://insanityprogresstracking.blogspot.com/2020/07/privacy-policy-of-insanity-progress.html"
    
    override func viewWillAppear(_ animated: Bool) { navigationController?.isNavigationBarHidden = false }
    override func viewWillDisappear(_ animated: Bool) { navigationController?.isNavigationBarHidden = true }
    
    override func loadView() {
        webView = WKWebView()
        
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))

    }
    
}
