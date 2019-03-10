//
//  SettingsViewController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var providerTextField: InsetTextField!
    @IBOutlet weak var itemStackView: BorderedStackView!
    @IBOutlet weak var devInfoItem: UIView!
    @IBOutlet weak var devInfoStackView: BorderedStackView!
    @IBOutlet weak var attrInfoItem: UIView!
    @IBOutlet weak var attrInfoStackView: BorderedStackView!
    @IBOutlet weak var clearButton: UIButton!
    
    // MARK: - Overriden Functions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        providerTextField.delegate = self
        
        // Border colors
        providerTextField.layer.borderColor = UIColorCollection.greyDark.cgColor
        providerTextField.layer.borderWidth = 1
        
        itemStackView.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        devInfoStackView.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        
        clearButton.layer.borderColor = UIColorCollection.greyDark.cgColor
        clearButton.layer.borderWidth = 1
        
        // Display ProviderName
        providerTextField.text = UserDefaults.standard.string(forKey: "ProviderName")
        
        // Add gesture recognizers
        let devTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        devTapRecognizer.minimumPressDuration = 0
        devInfoItem.addGestureRecognizer(devTapRecognizer)
        
        let attrTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        attrTapRecognizer.minimumPressDuration = 0
        attrInfoItem.addGestureRecognizer(attrTapRecognizer)
        
        let clearTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        clearTapRecognizer.minimumPressDuration = 0
        clearButton.addGestureRecognizer(clearTapRecognizer)
        
        // Dismiss keyboard on view tap
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Update the provider name
        if textField.text != "" {
            UserDefaults.standard.set(textField.text!, forKey: "ProviderName")
        } else {
            textField.text = UserDefaults.standard.string(forKey: "ProviderName")
        }
    }
    
    // MARK: - Actions
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .began {
            // Animate the touch
            sender.view!.backgroundColor = UIColorCollection.greyTap
        } else if sender.state == .ended {
            if sender.view!.bounds.contains(sender.location(ofTouch: 0, in: sender.view!)) {
                // Touch ended inside of view, perform action
                if sender.view!.isDescendant(of: itemStackView) {
                    // Move to correct view controller
                    print("Move to new controller!")
                } else if sender.view == clearButton {
                    // Undo animation and clear table
                    clearButton.backgroundColor = UIColor.white
                    print("Clear the table!")
                }
            } else {
                // Touch ended outside of view, undo animation
                sender.view!.backgroundColor = UIColor.white
            }
        }
    }
}
