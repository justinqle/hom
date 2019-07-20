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
        appNameView.layer.borderColor = UIColorCollection.greyBorder.cgColor
        appNameView.layer.borderWidth = 1
        devView.layer.borderColor = UIColorCollection.greyBorder.cgColor
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
        
        // Add gesture recognizers
        let deanTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        deanTapRecognizer.minimumPressDuration = 0
        deanCellView.addGestureRecognizer(deanTapRecognizer)
        
        let justinTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        justinTapRecognizer.minimumPressDuration = 0
        justinCellView.addGestureRecognizer(justinTapRecognizer)
    }
    
    //MARK: - Private Methods
    @objc private func viewTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // Animate the touch
            UIView.animate(withDuration: 0.1, animations: {
                sender.view!.backgroundColor = UIColorCollection.greyTap
            })
        } else if sender.state == .ended {
            if sender.view!.bounds.contains(sender.location(ofTouch: 0, in: sender.view!)) {
                // Touch ended inside view, open link
                if sender.view! == deanCellView {
                    UIApplication.shared.open(URL(string: "https://www.linkedin.com/in/dean-foster/")!, options: [:], completionHandler: nil)
                } else if sender.view! == justinCellView {
                    UIApplication.shared.open(URL(string: "https://www.linkedin.com/in/justinle99/")!, options: [:], completionHandler: nil)
                } else {
                    fatalError("Invalid sender!")
                }
            }
            
            // Undo animation
            UIView.animate(withDuration: 0.1, animations: {
                sender.view!.backgroundColor = UIColor.white
            })
        }
    }
}
