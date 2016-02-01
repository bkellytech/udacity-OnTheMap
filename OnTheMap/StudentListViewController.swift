//
//  StudentListViewController.swift
//  OnTheMap
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class StudentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //class variables
    var students: [StudentInformation] = ParseManager.sharedInstance().studentLocations
    
    //UI Outlets
    @IBOutlet weak var studentListView: UITableView!
    
    //Overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createTableView()
    }
    
    //Tableview methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCellWithIdentifier("studentCell") as? UITableViewCell?)!
        let image: UIImage = UIImage(named: "addItem")!
        cell?.imageView!.image = image
        let student = students[indexPath.row]
        cell?.textLabel!.text = "\(student.firstName) \(student.lastName)"
        //cell?.detailTextLabel!.text = "\(student.mapString)"
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
    }
    
    
    
    //Utility Functions
    //Get Data
    func createTableView() {
        ParseManager.sharedInstance().getStudentLocationsUsingCompletionHandler() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.students = ParseManager.sharedInstance().studentLocations
                    self.studentListView.reloadData()
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
    
    
    // Refresh Data
    func refreshView() {
        createTableView()
    }
}

