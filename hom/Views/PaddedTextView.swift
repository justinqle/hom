//
//  PaddedTextView.swift
//  hom
//
//  Created by Dean  Foster on 1/31/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

@IBDesignable
class PaddedTextView: UITextView {
    
    // MARK: Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 0, right: 0)
        
        // Placeholder text
        self.text = "No notes"
        self.textColor = UIColorCollection.placeHolderGrey
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textContainerInset = UIEdgeInsets(top: 4, left: 12, bottom: 0, right: 0)
        
        // Placeholder text
        self.text = "No notes"
        self.textColor = UIColorCollection.placeHolderGrey
    }
}
