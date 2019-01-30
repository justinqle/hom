//
//  InsetableTextField.swift
//  hom
//
//  Created by Dean  Foster on 1/28/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class BorderInsetView: UITextField {
    @IBInspectable var inset: CGFloat = 0
    @IBInspectable var bottomBorder: Bool = false
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if bottomBorder {
            addBottomBorderWithColor(color: UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1), width: 1)
        }
    }
}

extension UIView {
    
}
