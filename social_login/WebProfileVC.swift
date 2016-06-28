//
//  WebProfileVC.swift
//  social_login
//
//  Created by David Jiang on 6/28/16.
//  Copyright © 2016 David Jiang. All rights reserved.
//

import Foundation
import UIKit

class WebProfileVC: UIViewController {
    var linkedinProfileURL : String?
    
    @IBOutlet weak var webView: UIWebView!
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(linkedinProfileURL != nil) {
            let request = NSURLRequest(URL: NSURL(string: linkedinProfileURL!)!)
            webView.loadRequest(request)
        }
    }
    
}