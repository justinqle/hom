//
//  BorderedTextField.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedTextField: InsetTextField {
    override var bounds: CGRect {
        didSet {
            updateBottomBorder(color: UIColorCollection.greyBorder, width: 1, shouldAdd: false)
        }
    }
    
    private var lastBorder = CALayer()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateBottomBorder(color: UIColorCollection.greyBorder, width: 1, shouldAdd: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateBottomBorder(color: UIColorCollection.greyBorder, width: 1, shouldAdd: true)
    }
    
    // MARK: Private Methods
    private func updateBottomBorder(color: UIColor, width: CGFloat, shouldAdd: Bool) {
        lastBorder.backgroundColor = color.cgColor
        lastBorder.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        if shouldAdd {
            self.layer.addSublayer(lastBorder)
        }
    }
}
