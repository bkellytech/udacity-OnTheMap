//
//  LoginCredential.swift
//  OnTheMap
//
//  Created by Brendan Kelly on 1/30/16.
//  Copyright © 2016 admin. All rights reserved.
//

import Foundation

class LoginCredential : NSObject {
    
    //class variables
    var userName: String =  ""
    var passWord: String = ""
    
    init(username: String, password: String) {
        userName = username
        passWord = password
    }
}
