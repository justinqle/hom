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

    @IBOutlet weak var ageTextField: BorderedTextField!
    @IBOutlet weak var diagnosisStackView: BorderedStackView!

    @IBOutlet weak var dosageStackView: BorderedStackView!
    @IBOutlet weak var prescriptionTextField: SearchTextField!

    @IBOutlet weak var notesTextView: PaddedTextView!
    @IBOutlet weak var creationLabel: PaddedLabel!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private let options = Options.shared
    private var activeInput: UIView?
    private let pickerView = UIPickerView()
    private var activePickerTrigger: UIStackView?
    
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
        prescriptionTextField.delegate = self
        notesTextView.delegate = self
        pickerView.delegate = self
        
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
        prescriptionTextField.theme.font = UIFont.systemFont(ofSize: 18)
        prescriptionTextField.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.prescriptionTextField.text = item.title
            self.prescriptionTextField.resignFirstResponder()
        }
        
        // Configure UIPickerView
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        // Configure tap recorgnizers to UIStackViews that trigger pickers
        genderStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EntryAdditionController.pickerShouldTrigger(sender:))))
        diagnosisStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EntryAdditionController.pickerShouldTrigger(sender:))))
        dosageStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EntryAdditionController.pickerShouldTrigger(sender:))))
        
        // Dismiss the keyboard on tap of the content
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Register observers for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeInput = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeInput = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeInput = nil
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeInput = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeInput = nil
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let trigger = activePickerTrigger!
        
        switch trigger {
        case genderStackView:
            return options.genderList.count
        case diagnosisStackView:
            return options.diagnosisList.count
        case dosageStackView:
            return options.dosageList.count
        default:
            fatalError("Invalid picker trigger: \(trigger)")
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let trigger = activePickerTrigger else {
            fatalError("Picker should not have been shown!")
        }
        
        switch trigger {
        case genderStackView:
            return options.genderList[row]
        case diagnosisStackView:
            return options.diagnosisList[row]
        case dosageStackView:
            return options.dosageList[row]
        default:
            fatalError("Invalid picker trigger: \(trigger)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row selected: \(row)")
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
        
        if case let textView as UITextView = activeInput {
            // Calculate the difference between bottom of active TextView and top of keyboard
            guard let viewOrigin = textView.superview?.convert(textView.frame.origin, to: nil) else {
                return
            }
            // Difference + borderedStackView bottom margins set in IB
            let bottomFieldY = viewOrigin.y + textView.frame.height
            difference = bottomFieldY - keyboardFrame.minY + 20
        }
        else if var view = activeInput {
            if case let superView as BorderedStackView = view.superview {
                // If the superview is a BorderedStackView, use that instead
                view = superView
            }
            
            // Calculate the difference between bottom of active view (or its superview) and top of keyboard
            guard let viewOrigin = view.superview?.convert(view.frame.origin, to: nil) else {
                return
            }
            let bottomFieldY = viewOrigin.y + view.frame.height
            difference = bottomFieldY - keyboardFrame.minY
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
    
    @objc private func pickerShouldTrigger(sender: UIGestureRecognizer) {
        // Set the active trigger
        activePickerTrigger = sender.view as? UIStackView
        
        // Display the picker view
        guard let innerField = activePickerTrigger?.subviews[1] as? UITextField else {
            fatalError("Trigger does not have inner TextField!")
        }
        
        innerField.inputView = pickerView
        innerField.tintColor = UIColor.clear
        innerField.becomeFirstResponder()
    }
}
