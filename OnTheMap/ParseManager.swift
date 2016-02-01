//
//  ParseManager.swift
//  OnTheMap
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation

class ParseManager: NSObject {
    
    //constants
    let baseURL : String = "https://api.parse.com/1/classes/"
    let apiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let applicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    // shared array for student locations
    var studentLocations: [StudentInformation] = []
    

    let urlForGetRequest = "https://api.parse.com/1/classes/"
    let urlForPostRequest = "https://api.parse.com/1/classes/StudentLocation"
    
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    
    // retrieve last 100 students and add them to the studentLocations array
    func getStudentLocationsUsingCompletionHandler(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + "StudentLocation?limit=100" )!)
        request.addValue(applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Could not connect to the network")
            } else {
            
                //parse the result
                let parsedResult: AnyObject!
                
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    completionHandler(success: false, errorString: "Could not understand response from Server")
                }
                
                if let errorMessage = parsedResult["error"] as? String {
                    print("ERROR MESSAGE RECEIVED")
                    completionHandler(success: false, errorString: errorMessage)
                }
                
                //use the data
                if let topLevelDict = parsedResult {
                    let studentsArray = topLevelDict["results"] as! NSArray
                    self.studentLocations = []
                    for studentDictionary in studentsArray {
                        if let student = self.studentLocationFromDictionary(studentDictionary as! NSDictionary) {
                            self.studentLocations.append(student)
                        }
                    }
                }
                

                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
    
    // post the A Location to Parse
   func postStudentLocation(userKey: String, firstName: String, lastName: String, mediaURL: String, locationString: String, locationLatitude: String, locationLongitude: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlForPostRequest)!)
        request.HTTPMethod = "POST"
        request.addValue(applicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(userKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mapString\": \"\(locationString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(locationLatitude), \"longitude\": \(locationLongitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Unable to connect to Server")
            } else {
                //Parse Data
                let parsedResult: AnyObject!
                
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    if parsedResult["createdAt"] != nil {
                        completionHandler(success: true, errorString: nil)
                    } else {
                        completionHandler(success: false, errorString: "An unknown error occurred")
                    }
                } catch {
                    parsedResult = nil
                    completionHandler(success: false, errorString: "Could not understand response from Server")
                }



            }
        }
        task.resume()
    }
    
    
    //Utility functions
    func studentLocationFromDictionary(studentDictionary: NSDictionary) -> StudentInformation? {
        let studentFirstName = studentDictionary["firstName"] as! String
        let studentLastName = studentDictionary["lastName"] as! String
        let studentLongitude = studentDictionary["longitude"] as! Float!
        let studentLatitude = studentDictionary["latitude"] as! Float!
        let studentMediaURL = studentDictionary["mediaURL"] as! String
        let studentMapString = studentDictionary["mapString"] as! String
        let studentObjectID = studentDictionary["objectId"] as! String
        let studentUniqueKey = studentDictionary["uniqueKey"] as! String
        let initializerDictionary = ["firstName": studentFirstName, "lastName": studentLastName, "longitude": studentLongitude, "latitude": studentLatitude, "mediaURL": studentMediaURL, "mapString": studentMapString, "objectID": studentObjectID, "uniqueKey": studentUniqueKey]
        return StudentInformation(initializerDictionary: initializerDictionary as! [String:AnyObject])
    }

    
    //overrides
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }
    
    //Make this a singleton
    class func sharedInstance() -> ParseManager {
        struct Singleton {
            static var sharedInstance = ParseManager()
        }
        
        return Singleton.sharedInstance
    }
}

