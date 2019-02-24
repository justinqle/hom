//
//  DiagnosisCell.swift
//  hom
//
//  Created by Dean  Foster on 2/20/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class DiagnosisCell: UITableViewCell {
    @IBOutlet weak var diagnosisTextField: PickerTextField!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
}
