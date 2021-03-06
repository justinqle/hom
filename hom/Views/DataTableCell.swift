//
//  DataTableCell.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class DataTableCell: UITableViewCell {
    
    // MARK - Properties
    
    @IBOutlet weak var patientID: UILabel!
    @IBOutlet weak var clinicName: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var diagnosesCount: UILabel!
    @IBOutlet weak var diagnoses: UILabel!
    @IBOutlet weak var prescriptionCount: UILabel!
    @IBOutlet weak var prescriptions: UILabel!
    
    // MARK - Overriden Methods
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
