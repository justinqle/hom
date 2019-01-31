//
//  PaddedTextView.swift
//  hom
//
//  Created by Dean  Foster on 1/31/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class PaddedTextView: UITextView {
    
    // MARK: Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addLeftPadding()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addLeftPadding()
    }
    
    private func addLeftPadding() {
        textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 0, right: 0)
    }
}
