//
//  InsetTextField.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class InsetTextField: UITextField {
    
    // MARK: Properties
    @IBInspectable var xInset: CGFloat = 0
    @IBInspectable var yInset: CGFloat = 0
    
    // MARK: Drawing
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: xInset, dy: yInset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

