//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    
    //UI Outlets
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    //UI Actions
    @IBAction func openSignUp(sender: UIButton) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        if !validateFields() {
            lblError.text = "Please Enter a Valid Username and Password"
         } else {
            let loginCredential = LoginCredential(username: txtEmailAddress.text!, password: txtPassword.text!)
            UdacityManager.sharedInstance().loginAndCreateSession(loginCredential, completionHandler: {
                (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(errorAlert, animated: true, completion: nil)
                    })
                }
            })
            
        }
    }
    
    
    
    //Utility Functions
    func validateFields() -> Bool {
        
        if (txtEmailAddress.text == nil || txtPassword.text == nil) {
            return false
        }
        
        if (txtEmailAddress.text == "" || txtPassword.text == "") {
            return false
        }
        
        if txtEmailAddress.text == "Enter Email Address" || txtPassword.text == "Enter Password" {
            return false
            
        }
        return true
    }
    

    
    // Login and present next view
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let firstViewController = self.storyboard!.instantiateViewControllerWithIdentifier("rootNavController") as! UINavigationController
            self.presentViewController(firstViewController, animated: true, completion: nil)
        })
    }
    

    
}