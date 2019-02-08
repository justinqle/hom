//
//  EntryAdditionController.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class EntryAdditionController: UIViewController,
    UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate,
    UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var patientLabel: UILabel!
    @IBOutlet weak var providerTextField: InsetTextField!
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var clinicTextField: BorderedTextField!
    @IBOutlet weak var genderStackView: BorderedStackView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageTextField: BorderedTextField!
    @IBOutlet weak var diagnosisStackView: BorderedStackView!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var dosageStackView: BorderedStackView!
    @IBOutlet weak var prescriptionTextField: SearchTextField!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var notesTextView: PaddedTextView!
    @IBOutlet weak var creationLabel: PaddedLabel!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private let options = Options.shared
    private var activeView: UIView?
    
    // MARK: - Overriden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ScrollView content size
        scrollView.contentSize = contentView.frame.size
        scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        providerTextField.delegate = self
        clinicTextField.delegate = self
        ageTextField.delegate = self
        notesTextView.delegate = self
        
        // Provider TextField borders
        providerTextField.layer.borderColor = UIColorCollection.greyDark.cgColor
        providerTextField.layer.borderWidth = 1
        
        // Form view container borders
        patientInfoView.layer.borderColor = UIColorCollection.greyDark.cgColor
        patientInfoView.layer.borderWidth = 1
        
        // Button view container borders
        deleteButtonView.layer.borderColor = UIColorCollection.greyDark.cgColor
        deleteButtonView.layer.borderWidth = 1
        
        // Customize SearchTextField instance for prescriptions
        prescriptionTextField.filterStrings(options.medicationList)
        prescriptionTextField.inlineMode = true
        
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
        activeView = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeView = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeView = nil
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeView = nil
    }
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        let keyboardFrame = keyboardSize.cgRectValue
        
        var difference: CGFloat = 0
        
        if let textField = activeView {
            // Calculate the difference between bottom of active view and top of keyboard
            guard let fieldOrigin = textField.superview?.convert(textField.frame.origin, to: nil) else {
                return
            }
            let bottomFieldY = fieldOrigin.y + textField.frame.height
            difference = bottomFieldY - keyboardFrame.minY
        }
        else if let textView = activeView {
            // Calculate the difference between bottom of active view and top of keyboard
            guard let viewOrigin = textView.superview?.convert(textView.frame.origin, to: nil) else {
                return
            }
            // Difference + borderedStackView bottom margins set in IB
            let bottomFieldY = viewOrigin.y + textView.frame.height
            difference = bottomFieldY - keyboardFrame.minY + 20
        }
        
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
        // Reset the height and content offset if needed
        
    }
}
