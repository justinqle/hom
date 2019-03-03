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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameTextField: BorderedTextField!
    @IBOutlet weak var exportButton: UIButton!
    
    // MARK: - Overridden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        // Assign delegate
        nameTextField.delegate = self
        
        // Set button default state
        exportButton.backgroundColor = UIColorCollection.greyLight
        exportButton.setTitleColor(UIColorCollection.greyDark, for: .disabled)
        exportButton.isEnabled = false
        
        // Dismiss the keyboard on tap of the content
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
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
        
        exportButton.backgroundColor = UIColorCollection.greyLight
        exportButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            exportButton.isEnabled = true
            exportButton.backgroundColor = UIColorCollection.accentOrange
            var name = nameTextField.text!.components(separatedBy: ".")[0]
            name = name.trimmingCharacters(in: [" "])
            nameTextField.text = name + ".csv"
        }
    }
    
    // MARK: - Actions
    
    @IBAction func exportTouchDown(_ sender: Any) {
        // The touch began
        UIView.animate(withDuration: 0.1, animations: {
            self.exportButton.backgroundColor = UIColorCollection.accentOrangeLight
            self.exportButton.setTitleColor(UIColorCollection.whiteDark, for: UIControl.State.normal)
        })
    }
    
    @IBAction func exportDragExit(_ sender: Any) {
        // The touch was dragged outside of the button
        UIView.animate(withDuration: 0.25, animations: {
            self.exportButton.backgroundColor = UIColorCollection.accentOrange
            self.exportButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        })
    }
    
    @IBAction func exportTouchUpInside(_ sender: Any) {
        // The touch ended inside the button
        UIView.animate(withDuration: 0.25, animations: {
            self.exportButton.backgroundColor = UIColorCollection.accentOrange
            self.exportButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        })
        
        // Export the table
        print("Export table!")
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
