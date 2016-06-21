//
//  GoogleProfileVC.swift
//  social_login
//
//  Created by David Jiang on 6/20/16.
//  Copyright © 2016 David Jiang. All rights reserved.
//

import Foundation
import UIKit

class GoogleProfileVC : UIViewController, UIWebViewDelegate {
    
    var nameVar : String?
    var emailVar : String?
    var profileVar : String?
    var profileUrlVar : String?
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var subFieldLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        self.nameLabel.text = nameVar
        self.emailLabel.text = emailVar
        if let url = NSURL(string: profileVar!) {
            if let data = NSData(contentsOfURL: url) {
                self.profilePicture.image = UIImage(data: data)
            }
        }
        
        self.subFieldLabel.text = profileUrlVar
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "toMain") {
            var svc = segue.destinationViewController as? ViewController
            svc?.onBoarded = true
        }
    }

    @IBAction func tapped(sender: AnyObject) {
        if(profileUrlVar != nil) {
            let request = NSURLRequest(URL: NSURL(string: profileUrlVar!)!)
            webView.loadRequest(request)
        }
        
    }
}