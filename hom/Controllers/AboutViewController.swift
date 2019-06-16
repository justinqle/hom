//
//  AboutViewController.swift
//  hom
//
//  Created by Dean  Foster on 6/16/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var appNameView: UIView!
    @IBOutlet weak var HOMTextView: UITextView!
    
    //MARK: - Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Border colors
        appNameView.layer.borderColor = UIColorCollection.greyDark.cgColor
        appNameView.layer.borderWidth = 1
        
        // Configure HOM TextView
        HOMTextView.textContainer.lineFragmentPadding = 0
        HOMTextView.textContainerInset = .zero
        HOMTextView.textContainer.maximumNumberOfLines = 1
        HOMTextView.textContainer.lineBreakMode = .byTruncatingTail
    }
}
