//
//  Options.swift
//  hom
//
//  Created by Dean  Foster on 2/6/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation

class Options {
    
    // MARK: - Properties
    static let shared = Options()
    
    let genderList = ["Male", "Female"]
    let diagnosisList = ["GERD", "HTN", "Arthritis", "Undernourished", "URI",
                                 "Headache", "Anemia", "Vaginitis", "Iron deficiency",
                                 "Rash", "Pain", "Diabetes", "Worried Well", "Cough", "Fever"]
    let dosageList = ["One time", "One week", "One month", "3 month"]
    private (set) var medicationList: [String] = []
    
    // MARK: - Initializer
    private init() {
        // Find the CSV containing full medication list
        guard let path = Bundle.main.path(forResource: "Medications", ofType: "csv") else {
            fatalError("Medications CSV not found!")
        }
        
        // Read the file
        do {
            let contents = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            medicationList = fromCSV(data: contents)
            
            // Sort diagnoses
            diagnosisList.sort(by: <)
        } catch {
            fatalError("Could not read Medications in: \(path)")
        }
    }
    
    // MARK: - Private Methods
    private func fromCSV(data: String) -> [String] {
        // Collect the entries in the first column of the CSV
        var result: [String] = []
        let rows = data.components(separatedBy: "\r")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            let filtered = columns[0].replacingOccurrences(of: "\n", with: "")
            result.append(filtered)
        }
        result.removeFirst(1)
        return result
    }
}
