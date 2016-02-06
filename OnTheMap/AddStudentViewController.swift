//
//  AddStudentViewController.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/31/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import MapKit

class AddStudentViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    //class variables
    // values to be passed in from the existing Udacity session
    var firstName: String = UdacityManager.sharedInstance().firstName
    var lastName: String = UdacityManager.sharedInstance().lastName
    var userKey: String = UdacityManager.sharedInstance().userKey
    var mapString: String = ""
    var locationString: String = ""
    var locationLatitude: String = ""
    var locationLongitude: String = ""
    var mediaURL: String = ""
    
    
    //UI Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var addMapView: MKMapView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnFindOnMapSubmit: UIButton!
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblStudying: UILabel!
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var txtEnterLocation: UITextField!
    @IBOutlet weak var txtShareURL: UITextField!

    
     //UI Actions
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    @IBAction func btnFindOnMapSubmitPressed(sender: AnyObject) {
        
        if btnFindOnMapSubmit.titleLabel?.text == "Find on the Map" {
            findPressed()
        } else {
            submitPressed()
        }
        
    }

    
    //overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        setLocationViews()
        showFindOnTheMapViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtEnterLocation.delegate = self
        txtShareURL.delegate = self
    }

    func setLocationViews() {

        txtEnterLocation.text = "Enter Your Location Here"
        txtShareURL.text = "Enter a Link to Share Here"
        txtShareURL.leftViewMode = UITextFieldViewMode.Always
        
    }
    
    
    // show or hide activity spinner
    func lockUI() {
        //lock out UI
        btnFindOnMapSubmit.enabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func unlockUI() {
        btnFindOnMapSubmit.enabled = true
        activityIndicator.stopAnimating()
    }
    


    func showFindOnTheMapViews() {

        btnFindOnMapSubmit.setTitle("Find on the Map", forState: .Normal)
        
        middleView.hidden = false
        txtEnterLocation.hidden = false
        lblWhere.hidden = false
        lblStudying.hidden = false
        lblToday.hidden = false
        
        txtShareURL.hidden = true
        addMapView.hidden = true
    }
    

    func showSubmitSubviews() {
        // set attributes for shared subviews
        btnFindOnMapSubmit.setTitle("Submit", forState: .Normal)
        
        middleView.hidden = true
        txtEnterLocation.hidden = true
        lblWhere.hidden = true
        lblStudying.hidden = true
        lblToday.hidden = true
        
        // show second group subviews
        txtShareURL.hidden = false
        addMapView.hidden = false
    }
    
    // "Find on the Map" button pressed
    func findPressed() {
        
        if txtEnterLocation.text!.isEmpty || txtEnterLocation.text! == "Enter Your Location Here" {
            let emptyStringAlert = UIAlertController(title: "Please enter your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            emptyStringAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyStringAlert, animated: true, completion: nil)
            return
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.lockUI()
            })
            locationString = txtEnterLocation.text!

            getLatitudeAndLongitude(locationString)
            

        }
    }
    

    func submitPressed() {
        if txtShareURL.text!.isEmpty {
            let emptyStringAlert = UIAlertController(title: "Please enter a link to share", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            emptyStringAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(emptyStringAlert, animated: true, completion: nil)
            return
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.lockUI()
            })
            mediaURL = txtShareURL.text!
            ParseManager.sharedInstance().postStudentLocation(userKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL, locationString: locationString, locationLatitude: locationLatitude, locationLongitude: locationLongitude) { (success, errorString) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.unlockUI()
                })
                
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
        
    }
    
    // Get the geocoordinates for the location string
    func getLatitudeAndLongitude(location: String) {

        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(location) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?[0]  {
                    let coordinates = placemark.location!.coordinate
                    
                    //Setup data for submission
                    self.locationLatitude = String(coordinates.latitude)
                    self.locationLongitude = String(coordinates.longitude)
                    self.mapString = location
                    
                    let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(0.5, 0.5))
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    self.addMapView.addAnnotation(annotation)
                    
                    //Reconfigure display
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if !self.mediaURL.isEmpty {
                            self.txtShareURL.text = self.mediaURL
                        } else {
                            self.txtShareURL.text = "Enter a Link to Share Here"
                        }
                        
                        self.addMapView.alpha = 1.0
                        self.addMapView.setRegion(region, animated: true)
                        self.unlockUI()
                    }
                }
                self.showSubmitSubviews()
            } else {
                let alert = UIAlertController(title: "Location not added", message: "Sorry we couldn't find that location.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.txtShareURL.text = ""
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func setMapViewScale(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.13, 0.13)
        let region = MKCoordinateRegion(center: location, span: span)
        addMapView.setRegion(region, animated: true)
        locationLatitude = "\(location.latitude)"
        locationLongitude = "\(location.longitude)"
    }
    
    //remove keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
}