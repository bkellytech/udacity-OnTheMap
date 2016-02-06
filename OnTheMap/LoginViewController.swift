//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate  {
    
    
    //UI Outlets
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnLogin: UIButton!
    
    //UI Actions
    @IBAction func openSignUp(sender: UIButton) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        if !validateFields() {
            //show bad username error
            dispatch_async(dispatch_get_main_queue(), {
                let errorAlert = UIAlertController(title: "Required", message: "Please Enter a Valid Udacity Username and Password", preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            })
         } else {
            
            //lock out the buttons and display a beachball
            lockUI()
            
            let loginCredential = LoginCredential(username: txtEmailAddress.text!, password: txtPassword.text!)
            UdacityManager.sharedInstance().loginAndCreateSession(loginCredential, completionHandler: {
                (success, errorString) in
                
                if success {
                    
                    //unlock the ui
                    dispatch_async(dispatch_get_main_queue()) {
                        self.unlockUI()
                    }
                    
                    //store session and move to next screen
                    self.completeLogin()
                } else {
                    //unlock the ui
                    dispatch_async(dispatch_get_main_queue()) {
                        self.unlockUI()
                    }
                    //show error
                    dispatch_async(dispatch_get_main_queue(), {
                        let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(errorAlert, animated: true, completion: nil)
                    })
                }
            })
            
            
        }
    }
    
    //overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmailAddress.delegate = self
        txtPassword.delegate = self
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
    
    
    func lockUI() {
        //lock out UI
        btnLogin.enabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func unlockUI() {
        btnLogin.enabled = true
        activityIndicator.stopAnimating()
    }
    
    
    /* Keyboard functions to show and hide keyboard */
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        if txtPassword.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if txtPassword.isFirstResponder(){
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    //txt delegate remove keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}