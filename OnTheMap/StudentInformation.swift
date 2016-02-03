//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/30/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation

struct StudentInformation {
    let firstName: String
    let lastName: String
    let longitude: Float
    let latitude: Float
    let mediaURL: String
    let mapString: String
    let objectID: String
    let uniqueKey: String
    let updatedAt: String!
    
    init(initializerDictionary: [String: AnyObject]) {
        self.firstName = initializerDictionary["firstName"] as! String!
        self.lastName = initializerDictionary["lastName"] as! String!
        self.longitude = initializerDictionary["longitude"] as! Float
        self.latitude = initializerDictionary["latitude"] as! Float
        self.mediaURL = initializerDictionary["mediaURL"] as! String!
        self.mapString = initializerDictionary["mapString"] as! String!
        self.objectID = initializerDictionary["objectID"] as! String!
        self.uniqueKey = initializerDictionary["uniqueKey"] as! String!
        self.updatedAt = initializerDictionary["updatedAt"] as! String
    }
}
