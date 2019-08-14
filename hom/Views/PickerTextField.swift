//
//  PickerTextField.swift
//  hom
//
//  Created by Dean  Foster on 2/8/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class PickerTextField: UITextField, UITableCellSubView {
    
    // MARK: - Properties
    enum PickerType: String {
        case gender = "Gender"
        case diagnosis = "Diagnosis"
        case dosage = "Dosage"
        case quantity = "Quantity"
    }
    
    var pickerOptions: PickerType?
    var parentCell: UITableViewCell?
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = UIColor.clear
        self.autocorrectionType = .no
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tintColor = UIColor.clear
        self.autocorrectionType = .no
    }
    
    // MARK: - Overriden Methods
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
}
