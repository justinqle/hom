//
//  BorderedStackView.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedStackView: UIStackView {
    @IBInspectable var top: Bool = false
    @IBInspectable var bottom: Bool = false
    @IBInspectable var left: Bool = false
    @IBInspectable var right: Bool = false
    override var bounds: CGRect {
        didSet {
            updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        }
    }
    
    private lazy var topBorder = CALayer()
    private lazy var bottomBorder = CALayer()
    private lazy var leftBorder = CALayer()
    private lazy var rightBorder = CALayer()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
    }
    
    // MARK: Private Methods
    func updateBorders(color: UIColor, borderThickness: CGFloat) {
        if top {
            topBorder.backgroundColor = color.cgColor
            topBorder.frame = CGRect(x: 0, y: borderThickness, width: self.frame.size.width, height: borderThickness)
            if topBorder.superlayer == nil {
                self.layer.addSublayer(topBorder)
            }
        }
        
        if bottom {
            bottomBorder.backgroundColor = color.cgColor
            bottomBorder.frame = CGRect(x: 0, y: self.frame.size.height - borderThickness, width: self.frame.size.width, height: borderThickness)
            if bottomBorder.superlayer == nil {
                self.layer.addSublayer(bottomBorder)
            }
        }
        
        if left {
            leftBorder.backgroundColor = color.cgColor
            leftBorder.frame = CGRect(x: 0, y: 0, width: borderThickness, height: self.frame.size.height)
            if leftBorder.superlayer == nil {
                self.layer.addSublayer(leftBorder)
            }
        }
        
        if right {
            rightBorder.backgroundColor = color.cgColor
            rightBorder.frame = CGRect(x: self.frame.size.width - borderThickness, y: 0, width: borderThickness, height: self.frame.size.height)
            if rightBorder.superlayer == nil {
                self.layer.addSublayer(rightBorder)
            }
        }
    }
}
