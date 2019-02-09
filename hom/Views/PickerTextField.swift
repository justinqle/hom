//
//  PickerTextField.swift
//  hom
//
//  Created by Dean  Foster on 2/8/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class PickerTextField: UITextField {
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tintColor = UIColor.clear
    }
    
}
