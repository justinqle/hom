//
//  InsetTextField.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class InsetTextField: UITextField, UITableCellSubView {
    
    // MARK: Properties
    @IBInspectable var xInsetLeft: CGFloat = 0
    @IBInspectable var xInsetRight: CGFloat = 0
    @IBInspectable var yInsetTop: CGFloat = 0
    @IBInspectable var yInsetBottom: CGFloat = 0
    
    var parentCell: UITableViewCell?
    
    // MARK: Drawing
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: yInsetTop, left: xInsetLeft, bottom: yInsetBottom, right: xInsetRight))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

