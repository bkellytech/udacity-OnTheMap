//
//  UdacityManager.swift
//  OnTheMap
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation
import UIKit

class UdacityManager : NSObject {
    
    //constants
    let baseURL : String = "https://www.udacity.com/api/"
    
    //class variables
    var session: NSURLSession
    var sessionID: String
    var userKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var lat: Double
    var longitude: Double
    
    
    override init() {
        session = NSURLSession.sharedSession()
        userKey = ""
        sessionID = ""
        firstName = ""
        lastName = ""
        mapString = ""
        mediaURL = ""
        lat = 0.0
        longitude = 0.0
        
        super.init()
    }
    
    //API Functions
    func loginAndCreateSession(logincredentials: LoginCredential, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + "session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let myRequestString:String =  "{\"udacity\" : {\"username\":\"\(logincredentials.userName)\", \"password\": \"\(logincredentials.passWord)\"}}"
        request.HTTPBody = myRequestString.dataUsingEncoding(NSUTF8StringEncoding)

        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Could not connect to the network")
            } else {
                
                //udacity uses a very wacky security mechanism - the real response is offset 5 chars
                let receivedData = data!.subdataWithRange(NSMakeRange(5, data!.length-5))
                
                //parse the result
                let parsedResult: AnyObject!
               
                do {
                   parsedResult = try NSJSONSerialization.JSONObjectWithData(receivedData, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    completionHandler(success: false, errorString: "Could not understand response from Server")
                }
                
                if let errorMessage = parsedResult["error"] as? String {
                    completionHandler(success: false, errorString: errorMessage)
                }
                
                //use the data
                if let userAccount = parsedResult["account"] as? NSDictionary {
                    self.userKey = userAccount["key"] as! String
                    //have to make a second call for the name info
                    self.getUserData()
                }
                
                if let sessionInfo = parsedResult["session"] as? NSDictionary {
                    self.sessionID = sessionInfo["id"] as! String
                    print(self.sessionID)
                }
                
                //return success or failure
                if self.sessionID == "" || self.userKey == "" {
                    completionHandler(success: false, errorString: "Could Not Login")
                } else {
                    completionHandler(success: true, errorString: nil)
                }
            }
        
        }
        
        task.resume()
    }
    
    
    
    func logoutAndDeleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + "session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
            } else {
                let receivedData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                //parse the result
                let parsedResult: AnyObject!
                
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(receivedData,options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    completionHandler(success: false, errorString: "Could not understand response from Server")
                }
                
                if parsedResult["session"] != nil {
                    completionHandler(success: true, errorString: nil)
                } else {
                    completionHandler(success: false, errorString: "Could not logout")
                }
            }
        }
        task.resume()
    }
    
    func getUserData() {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + "users/\(userKey)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            } else {
                let receivedData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                //parse the result
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(receivedData,options: .AllowFragments)
                    if let user = parsedResult["user"] as? NSDictionary {
                        self.firstName = user["first_name"] as! String
                        self.lastName = user["last_name"] as! String
                    }
                } catch {
                    parsedResult = nil
                }
                
            }
        }
        task.resume()
    }
    
    
    //Make this a singleton
    class func sharedInstance() -> UdacityManager {
        struct Singleton {
            static var sharedInstance = UdacityManager()
        }
        
        return Singleton.sharedInstance
    }
}
