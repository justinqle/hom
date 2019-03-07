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
    @IBOutlet weak var devInfoItem: BorderedStackView!
    @IBOutlet weak var attrInfoItem: BorderedStackView!
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
        devInfoItem.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        
        clearButton.layer.borderColor = UIColorCollection.greyDark.cgColor
        clearButton.layer.borderWidth = 1
        
        // Item tap listeners
        let devTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:)))
        devInfoItem.addGestureRecognizer(devTapRecognizer)
        
        let attrTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.itemTapped(sender:)))
        attrInfoItem.addGestureRecognizer(attrTapRecognizer)
        
        // Display ProviderName
        providerTextField.text = UserDefaults.standard.string(forKey: "ProviderName")
        
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
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        print("Clear table!")
    }
    
    @objc private func itemTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIStackView else {
            fatalError("Invalid sender!")
        }
        
        // Tap anim
        guard let background = view.superview else {
            fatalError("Invalid superview!")
        }
        
        background.backgroundColor = UIColorCollection.greyDark
        
        // Move to appropriate scene
        
    }
}
