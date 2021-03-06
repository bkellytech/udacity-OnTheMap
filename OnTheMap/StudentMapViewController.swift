//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, MKMapViewDelegate {
    
    
    //Outlets
    @IBOutlet weak var studentMap: MKMapView!
    
    
    //overrides
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.studentMap.delegate = self
    }


    //Get Data
    func createMapView() {
        studentMap.removeAnnotations(studentMap.annotations)
        ParseManager.sharedInstance().getStudentLocationsUsingCompletionHandler() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.addStudentsToMap()
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
    
    
    //Add Students to map
    // loop through array to create an annotation for each
    func addStudentsToMap() {
        for student in StudentsList.sharedInstance.studentsList {
            createAnnotationFromSingleLocation(student)
        }
    }
    
    // create and set an annotation for each student
    func createAnnotationFromSingleLocation(student: StudentInformation) {
        let studentLatitude = CLLocationDegrees(student.latitude)
        let studentLongitude = CLLocationDegrees(student.longitude)
        let studentName = "\(student.firstName) \(student.lastName)"
        let studentURL = "\(student.mediaURL)"
        let annotationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: studentLatitude, longitude: studentLongitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = annotationLocation
        annotation.title = studentName
        annotation.subtitle = studentURL
        studentMap.addAnnotation(annotation)
    }

    
    
    //Map Delegate Methods
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            var studentURL = annotationView.annotation!.subtitle!
            if studentURL != nil && studentURL!.lowercaseString.rangeOfString("http") == nil {
                studentURL = "http://" + studentURL!
            }

            if let validURL: NSURL = NSURL(string: studentURL!) {
                //let request = NSURLRequest(URL: NSURL(string: studentURL)!)
                UIApplication.sharedApplication().openURL(validURL)
            }
            
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }

    // refresh
    func refreshView() {
        createMapView()
    }

}

