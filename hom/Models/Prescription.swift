//
//  Prescription.swift
//  hom
//
//  Created by Dean  Foster on 2/24/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation

public class Prescription: NSObject, NSCoding {
    var medicine: String
    var dosage: String
    var quantity: Int
    
    init(medicine: String, dosage: String, quantity: Int) {
        self.medicine = medicine
        self.dosage = dosage
        self.quantity = quantity
    }
    
    override public var description: String {
        return "{Medicine: \(self.medicine) | dosage: \(self.dosage) | quantity: \(self.quantity)}"
    }
    
    // MARK: - NSCoding
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(medicine, forKey: "medicine")
        aCoder.encode(dosage, forKey: "dosage")
        aCoder.encode(quantity, forKey: "quantity")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.medicine = aDecoder.decodeObject(forKey: "medicine") as! String
        self.dosage = aDecoder.decodeObject(forKey: "dosage") as! String
        self.quantity = aDecoder.decodeInteger(forKey: "quantity")
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        let p = object as? Prescription
        return medicine == p?.medicine
            && dosage == p?.dosage
            && quantity == p?.quantity
    }
    
    public override func copy() -> Any {
        return Prescription(medicine: medicine, dosage: dosage, quantity: quantity)
    }
}
