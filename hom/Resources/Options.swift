//
//  Options.swift
//  hom
//
//  Created by Dean  Foster on 2/6/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
import UIKit
import CSV

class Options {
    
    enum PatientKeys: String {
        case deleted = "delete"
        case creation = "creation"
        case clinic = "clinic"
        case id = "id"
        case sex = "sex"
        case age = "age"
        case diagnoses = "diagnoses"
        case prescriptions = "prescriptions"
        case notes = "notes"
    }
    
    // MARK: - Properties
    static let shared = Options()
    
    let genderList = ["Male", "Female"]
    var diagnosisList = ["GERD", "HTN", "Arthritis", "Undernourished", "URI",
                                 "Headache", "Anemia", "Vaginitis", "Iron deficiency",
                                 "Rash", "Pain", "Diabetes", "Worried Well", "Cough", "Fever"]
    let dosageList = ["1 time", "1 week", "1 month", "3 month"]
    private (set) var medicationList: [String] = []
    
    // MARK: - Initializer
    private init() {
        // Find the CSV containing full medication list
        guard let path = Bundle.main.path(forResource: "Medications", ofType: "csv") else {
            fatalError("Medications CSV not found!")
        }
        
        // Read the file
        let stream = InputStream(fileAtPath: path)!
        let csv = try! CSVReader(stream: stream)
        var count = 0
        while let row = csv.next() {
            if count > 0 {
                medicationList.append(row[0])
            }
            count += 1
        }
        
        // Sort diagnoses
        diagnosisList.sort(by: <)
    }
}
