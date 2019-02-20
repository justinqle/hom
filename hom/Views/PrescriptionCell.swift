//
//  PrescriptionCell.swift
//  hom
//
//  Created by Dean  Foster on 2/20/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class PrescriptionCell: UITableViewCell {
    @IBOutlet weak var prescriptionTextField: BorderedTextField!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
