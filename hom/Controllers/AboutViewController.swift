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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var appNameView: UIView!
    @IBOutlet weak var HOMTextView: UITextView!
    @IBOutlet weak var devView: UIView!
    @IBOutlet weak var deanCellView: UIView!
    @IBOutlet weak var deanImageView: UIImageView!
    @IBOutlet weak var justinImageView: UIImageView!
    @IBOutlet weak var justinCellView: UIView!
    
    //MARK: - Overriden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View border colors
        appNameView.layer.borderColor = UIColorCollection.greyDark.cgColor
        appNameView.layer.borderWidth = 1
        devView.layer.borderColor = UIColorCollection.greyDark.cgColor
        devView.layer.borderWidth = 1
        
        // TextViews
        HOMTextView.textContainer.lineFragmentPadding = 0
        HOMTextView.textContainerInset = .zero
        HOMTextView.textContainer.maximumNumberOfLines = 1
        HOMTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        // ImageViews
        deanImageView.layer.borderWidth = 1
        deanImageView.layer.masksToBounds = false
        deanImageView.layer.borderColor = UIColor.white.cgColor
        deanImageView.layer.cornerRadius = deanImageView.frame.height / 2
        deanImageView.clipsToBounds = true
        
        justinImageView.layer.borderWidth = 1
        justinImageView.layer.masksToBounds = false
        justinImageView.layer.borderColor = UIColor.white.cgColor
        justinImageView.layer.cornerRadius = deanImageView.frame.height / 2
        justinImageView.clipsToBounds = true
        
    }
}
