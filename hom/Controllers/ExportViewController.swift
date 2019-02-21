//
//  ExportViewController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
import UIKit

class ExportViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameTextField: BorderedTextField!
    @IBOutlet weak var exportButton: UIButton!
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        // Assign delegate
        nameTextField.delegate = self
        
        // Dismiss the keyboard on tap of the content
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Set button default state
        exportButton.backgroundColor = UIColorCollection.greyLight
        exportButton.setTitleColor(UIColorCollection.greyDark, for: .disabled)
        exportButton.isEnabled = false
        
        // Register observers for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text != "" {
            let name = text.components(separatedBy: ".")[0]
            textField.text = name
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            exportButton.backgroundColor = UIColorCollection.greyLight
            exportButton.isEnabled = false
        } else {
            exportButton.isEnabled = true
            exportButton.backgroundColor = UIColorCollection.accentOrange
            var name = nameTextField.text!.components(separatedBy: ".")[0]
            name = name.trimmingCharacters(in: [" "])
            nameTextField.text = name + ".csv"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func exportFile(_ sender: UIButton) {
        print("EXPORT!")
    }
    
    // MARK: - Private Methods
    
    @objc private func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found")
            return
        }
        
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            print("No keyboard frame found")
            return
        }
        
        let keyboardRect = keyboardSize.cgRectValue
        
        var difference: CGFloat = 0
        
        // Calculate the difference between bottom of active TextView and top of keyboard
        guard let viewOrigin = nameTextField.superview?.convert(nameTextField.frame.origin, to: nil) else {
            return
        }
        
        // Calculate difference
        let bottomFieldY = viewOrigin.y + nameTextField.frame.height
        difference = bottomFieldY - keyboardRect.minY
        
        if difference < 0 {
            // View is above keyboard - return
            return
        } else {
            // View is hidden by keyboard, scroll up by difference
            let contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y + difference)
            scrollView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        // Reset the content offset
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
