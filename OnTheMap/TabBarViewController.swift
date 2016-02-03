//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/31/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    

    
    // programmatically set navigation bar items
    override func viewDidLoad() {
        super.viewDidLoad()
        let addImg: UIImage = UIImage(named: "addItem")!
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        let addButton = UIBarButtonItem(image: addImg, style: UIBarButtonItemStyle.Plain, target: self, action: "addStudent")
        let rightButtons = [refreshButton, addButton]
        self.navigationItem.rightBarButtonItems = rightButtons
        self.navigationItem.leftBarButtonItem = logoutButton
        self.title = "On The Map"
    }
    
    // MARK: - Functions for Navigation Bar Actions
    
    // call UdacityClient to destroy session and logout
    func logout() {
        UdacityManager.sharedInstance().logoutAndDeleteSession() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
            }
        }
    }
    
    // refresh data
    func refresh() {
        if self.selectedIndex == 0 {
            let studentMapView = self.viewControllers![0] as! StudentMapViewController
            studentMapView.refreshView()
        } else if self.selectedIndex == 1 {
            let studentListView = self.viewControllers![1] as! StudentListViewController
            studentListView.refreshView()
        }
    }
    
    // modally present addStudent View
    func addStudent() {
        let addStudentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("addStudentViewController") as! AddStudentViewController
        presentViewController(addStudentViewController, animated: true, completion: nil)
    }
}