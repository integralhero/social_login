//
//  ViewController.swift
//  social_login
//
//  Created by David Jiang on 6/19/16.
//  Copyright © 2016 David Jiang. All rights reserved.
//

import UIKit
import Onboard

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var userName : String = ""
    var userEmail : String = ""
    var pictureURL : String = ""
    var onBoarded = false
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ShowGoogleProfile") {
            let svc = segue.destinationViewController as! GoogleProfileVC;
            svc.nameVar = userName
            svc.emailVar = userEmail
            svc.profileVar = pictureURL
        }
    }
    
    func googleBackendAuthenticate(token : String) {
        let customServerURI = "https://arcane-reaches-15965.herokuapp.com/auth"
        var postParams = "googleToken=\(token)"
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        
        let request = NSMutableURLRequest(URL: NSURL(string: customServerURI)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    self.userName = dataDictionary["name"] as! String
                    self.userEmail = dataDictionary["email"] as! String
                    self.pictureURL = dataDictionary["picture"] as! String
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("ShowGoogleProfile", sender: nil)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
            else {
                self.clearUserDefaults()
            }
        }
        
        task.resume()
    }
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            NSUserDefaults.standardUserDefaults().setObject(idToken, forKey: "GoogleAccessToken")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.googleBackendAuthenticate(idToken)
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    //TODO change button appearance if already logged in
    func generateOnboardingVC() -> OnboardingViewController {
        let firstPage = OnboardingContentViewController(title: "Social Login", body: "Connect to Google and LinkedIn", image: UIImage(named: "icon"), buttonText: "Get Started") { () -> Void in
            self.redirectToMain()
        }
        let onboardingVC = OnboardingViewController(backgroundImage: UIImage(named: "background"), contents: [firstPage])
        onboardingVC.shouldFadeTransitions = true
        onboardingVC.fadePageControlOnLastPage = true
        onboardingVC.shouldBlurBackground = true
        onboardingVC.allowSkipping = false
        onboardingVC.swipingEnabled = false
        onboardingVC.skipHandler = redirectToMain
        return onboardingVC
    }
    func redirectToMain() {
        self.dismissViewControllerAnimated(true, completion: {})
        onBoarded = true
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "876571922505-2diffe89v60dles5jjhpboog6s8c51ns.apps.googleusercontent.com"
        clearUserDefaults()
        if(!onBoarded) {
            self.presentViewController(generateOnboardingVC(), animated: false, completion: {})
        }
        
//        if(NSUserDefaults.standardUserDefaults().stringForKey("GoogleAccessToken") != nil) {
//            let googleToken = NSUserDefaults.standardUserDefaults().stringForKey("GoogleAccessToken")
//            googleBackendAuthenticate(googleToken!)
//        }
        // Uncomment to automatically sign in the user.
        //GIDSignIn.sharedInstance().signInSilently()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearUserDefaults() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
    }
    
    

}

