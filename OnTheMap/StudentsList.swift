//
//  StudentList.swift
//  OnTheMap
//
//  Created by admin on 2/1/16.
//  Copyright © 2016 admin. All rights reserved.
//


class StudentsList {
    
    var studentsList = [StudentInformation]()
    
    static let sharedInstance = StudentsList()
    
    private init() {}
    
}

extension StudentsList: SequenceType {
    typealias Generator = AnyGenerator<StudentInformation>
    
    func generate() -> AnyGenerator<StudentInformation> {
        // keep the index of the next car in the iteration
        var nextIndex = studentsList.count-1
        
        // Construct a AnyGenerator<Car> instance, passing a closure that returns the next car in the iteration
        return anyGenerator {
            if (nextIndex < 0) {
                return nil
            }
            return self.studentsList[nextIndex--]
        }
    }
}