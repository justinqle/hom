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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBottomBorderWithColor(color: UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1), width: 1)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
}
