//
//  Prescription.swift
//  hom
//
//  Created by Dean  Foster on 2/24/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
class Prescription: CustomStringConvertible {
    var description: String {
        return "Medicine: \(self.medicine) | dosage: \(self.dosage) | quantity: \(self.quantity)"
    }
    
    var medicine: String
    var dosage: String
    var quantity: Int
    
    init(medicine: String, dosage: String, quantity: Int) {
        self.medicine = medicine
        self.dosage = dosage
        self.quantity = quantity
    }
}
