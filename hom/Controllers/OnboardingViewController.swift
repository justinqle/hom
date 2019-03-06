//
//  OnboardingViewController.swift
//  hom
//
//  Created by Dean  Foster on 3/6/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var providerTextField: BorderedTextField!
    @IBOutlet weak var finishButton: UIButton!
    
    // MARK: - Overriden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates
        providerTextField.delegate = self
        
        // Dismiss keyboard on content tap
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable finish button
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Enable/disable finish button
    }
    
    
}
