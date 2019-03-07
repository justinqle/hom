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
        
        // Set button default state
        finishButton.backgroundColor = UIColorCollection.greyLight
        finishButton.setTitleColor(UIColorCollection.greyDark, for: .disabled)
        finishButton.isEnabled = false
        
        // Dismiss keyboard on content tap
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
        finishButton.backgroundColor = UIColorCollection.greyLight
        finishButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            finishButton.isEnabled = true
            finishButton.backgroundColor = UIColorCollection.accentOrange
        }
    }
    
    // MARK: - Actions
    @IBAction func finishTouchDown(_ sender: UIButton) {
        // The touch began
        UIView.animate(withDuration: 0.1, animations: {
            self.finishButton.backgroundColor = UIColorCollection.accentOrangeLight
            self.finishButton.setTitleColor(UIColorCollection.whiteDark, for: UIControl.State.normal)
        })
    }
    
    @IBAction func finishDragExit(_ sender: UIButton) {
        // The touch was dragged outside of the button
        UIView.animate(withDuration: 0.25, animations: {
            self.finishButton.backgroundColor = UIColorCollection.accentOrange
            self.finishButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        })
    }
    
    @IBAction func finishTouchUpInside(_ sender: UIButton) {
        // The touch ended inside the button
        UIView.animate(withDuration: 0.25, animations: {
            self.finishButton.backgroundColor = UIColorCollection.accentOrange
            self.finishButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        })
        
        // Save Provider Name during segue
        UserDefaults.standard.set(providerTextField.text!, forKey: "ProviderName")
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
        guard let viewOrigin = providerTextField.superview?.convert(providerTextField.frame.origin, to: nil) else {
            return
        }
        
        // Calculate difference
        let bottomFieldY = viewOrigin.y + providerTextField.frame.height
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
