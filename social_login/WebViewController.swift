//
//  WebViewController.swift
//  social_login
//
//  Created by David Jiang on 6/20/16.
//  Copyright © 2016 David Jiang. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: IBOutlet Properties
    
    @IBOutlet weak var webView: UIWebView!
    
    var nameVar : String?
    var profURLVar : String?
    var profPhotoVar : String?
    var headerVar : String?
    var shouldShow = false
    // MARK: Constants
    
    let linkedInKey = "75ak3vqwy3u1uo"
    
    let linkedInSecret = "ybgkuiyFh9d4fpSU"
    
    let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization"
    
    let accessTokenEndPoint = "https://www.linkedin.com/uas/oauth2/accessToken"
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        webView.delegate = self
        if(!shouldShow) {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        else {
            startAuthorization()
        }
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: IBAction Function
    
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = "https://dnjiang.com/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Create a random string based on the time intervale (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        // Set preferred scope.
        let scope = "r_basicprofile"
        
        
        // Create the authorization URL string.
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        print(authorizationURL)
        
        
        // Create a URL request and load it in the web view.
        let request = NSURLRequest(URL: NSURL(string: authorizationURL)!)
        webView.loadRequest(request)
    }
    
    
    func requestForAccessToken(authorizationCode: String) {
        let grantType = "authorization_code"
        
        let redirectURL = "https://dnjiang.com/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedInSecret)"
        
        // Convert the POST parameters into a NSData object.
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(URL: NSURL(string: accessTokenEndPoint)!)
        
        // Indicate that we're about to make a POST request.
        request.HTTPMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.HTTPBody = postData
        
        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        
        // Initialize a NSURLSession object.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // Make the request.
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "LIAccessToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.getLinkedinData(accessToken)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
            else {
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
        
        task.resume()
    }
    
    func getLinkedinData(token : String) {
        let customServerURI = "https://arcane-reaches-15965.herokuapp.com/auth"
        var postParams = "linkedinToken=\(token)"
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
                    
                    var firstName = dataDictionary["firstName"] as! String
                    var lastName = dataDictionary["lastName"] as! String
                    self.nameVar = firstName + " " + lastName
                    self.profURLVar = dataDictionary["publicProfileUrl"] as! String
                    self.profPhotoVar = dataDictionary["pictureUrl"] as! String
                    self.headerVar = dataDictionary["headline"] as! String
                    dispatch_async(dispatch_get_main_queue(), {
                        self.shouldShow = false
                        self.performSegueWithIdentifier("ShowProfile", sender: nil)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ShowProfile") {
            let svc = segue.destinationViewController as! GoogleProfileVC
            svc.nameVar = self.nameVar
            svc.emailVar = self.headerVar
            svc.profileVar = self.profPhotoVar
            svc.profileUrlVar = self.profURLVar
            svc.displayButton = true
        }
    }
    // MARK: UIWebViewDelegate Functions
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!
        print(url)
        
        if url.host == "dnjiang.com" {
            if url.absoluteString.rangeOfString("code") != nil {
                // Extract the authorization code.
                let urlParts = url.absoluteString.componentsSeparatedByString("?")
                let code = urlParts[1].componentsSeparatedByString("=")[1]
                
                requestForAccessToken(code)
            }
            else {
                self.dismissViewControllerAnimated(true, completion: {})
            }
        }
        
        
        return true
    }
    
}