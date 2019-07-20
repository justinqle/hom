//
//  AttributionViewController.swift
//  hom
//
//  Created by Dean  Foster on 6/27/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class AttributionViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconsLinkTextView: UITextView!
    @IBOutlet weak var CSVTextView: UITextView!
    @IBOutlet weak var CSVLinkTextView: UITextView!
    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var searchLinkTextView: UITextView!
    
    //MARK: - Overridden Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = contentView.frame.size
        
        CSVTextView.contentOffset = .zero
        searchTextView.contentOffset = .zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Icons8 link
        iconsLinkTextView.textContainer.lineFragmentPadding = 0
        iconsLinkTextView.textContainerInset = .zero
        iconsLinkTextView.textContainer.maximumNumberOfLines = 1
        iconsLinkTextView.textContainer.lineBreakMode = .byTruncatingTail

        // CSV license
        CSVTextView.textContainer.lineFragmentPadding = 0
        CSVTextView.textContainerInset = .zero

        // CSV link
        CSVLinkTextView.textContainer.lineFragmentPadding = 0
        CSVLinkTextView.textContainerInset = .zero
        CSVLinkTextView.textContainer.maximumNumberOfLines = 1
        CSVLinkTextView.textContainer.lineBreakMode = .byTruncatingTail

        // SearchTextView license
        searchTextView.textContainer.lineFragmentPadding = 0
        searchTextView.textContainerInset = .zero

        // SearchTextView link
        searchLinkTextView.textContainer.lineFragmentPadding = 0
        searchLinkTextView.textContainerInset = .zero
        searchLinkTextView.textContainer.maximumNumberOfLines = 1
        searchLinkTextView.textContainer.lineBreakMode = .byTruncatingTail
        
    }
}
