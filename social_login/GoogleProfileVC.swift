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
    var displayButton : Bool?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var subFieldLabel: UILabel!
    
    @IBAction func tappedBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if(displayButton!) {
            profileButton.hidden = false
        }
        else {
            profileButton.hidden = true
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
        if(segue.identifier == "toWebView") {
            var svc = segue.destinationViewController as? WebProfileVC
            svc?.linkedinProfileURL = self.profileUrlVar
            
        }
    }

    @IBAction func tapped(sender: AnyObject) {
        
        
    }
}