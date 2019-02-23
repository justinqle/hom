//
//  EntryAdditionController.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit
import CoreData
import os.log

class EntryAdditionController: UIViewController,
    UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate,
    UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate,
    UITableViewDataSource {
    
    // MARK: - Properties
    
    var patient: NSManagedObject?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var patientLabel: UILabel!
    @IBOutlet weak var providerTextField: InsetTextField!
    @IBOutlet weak var patientInfoView: UIView!
    @IBOutlet weak var clinicTextField: BorderedTextField!
    @IBOutlet weak var genderTextField: PickerTextField!
    @IBOutlet weak var ageTextField: BorderedTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notesTextView: PaddedTextView!
    @IBOutlet weak var creationLabel: PaddedLabel!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private let options = Options.shared
    private var activeInput: UIView?
    private let pickerView = UIPickerView()
    private var additionDate = Date()
    private var lastKeyboardFrame: CGRect?
    private var lastTextViewHeight: CGFloat = 0
    private let sectionHeaderHeight: CGFloat = 55
    
    private enum TableSection: Int {
        case diagnosis = 0, prescription, total
    }
    
    private struct Prescription {
        var medicine: String
        var dosage: String
        var quantity: Int
    }
    
    private var diagnoses = [String]()
    private var prescriptions = [Prescription]()
    
    // MARK: - Overriden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Get height of TextView
        if lastTextViewHeight == 0 {
            lastTextViewHeight = notesTextView.frame.height
        }
        
        // ScrollView content size
        scrollView.contentSize = contentView.frame.size
        scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init dummy data
        diagnoses.append(contentsOf: ["GERD", "Headache"])
        prescriptions.append(contentsOf: [Prescription(medicine: "Tylenol Children's", dosage: "1 week", quantity: 1),
                                          Prescription(medicine: "Asprin 325mg", dosage: "1 week", quantity: 2)])
        
        // Assign delegates
        clinicTextField.delegate = self
        genderTextField.delegate = self
        ageTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
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
        
        // Set editing on TableView
        tableView.setEditing(true, animated: true)
        
        // Customize GenderTextField input options
        genderTextField.inputView = pickerView
        genderTextField.pickerOptions = .gender
        
        // Configure UIPickerView
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        // Display current date and time
        let formatter = DateFormatter()
        formatter.dateFormat = "'Added' MMMM dd',' yyyy 'at' hh:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: additionDate)
        creationLabel.text = dateString
        
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField is PickerTextField {
            // Prevent user from interacting with the TextField while selecting
            textField.isUserInteractionEnabled = false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeInput = textField
        
        if textField == ageTextField {
            textField.text = ""
        } else if textField is PickerTextField {
            // Set default value for PickerTextField on input
            let pickerTrigger = textField as! PickerTextField
            pickerView.selectRow(0, inComponent: 0, animated: true)

            switch pickerTrigger.pickerOptions {
            case .gender:
                pickerTrigger.text = options.genderList[0]
            case .diagnosis:
                pickerTrigger.text = options.diagnosisList[0]
            case .dosage:
                pickerTrigger.text = options.dosageList[0]
            }
            
            // Refresh the UIPickerField values
            pickerView.reloadAllComponents()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeInput = nil
        
        if textField == ageTextField {
            if let text = textField.text {
                if text != "" {
                    let newText = text + " years old"
                    textField.text = newText
                }
            }
        } else if textField is PickerTextField {
            // Re-enable user interaction
            textField.isUserInteractionEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeInput = nil
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeInput = textView
        
        // Handle placeholder text
        if textView.textColor == UIColorCollection.placeHolderGrey {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Move down the ScrollView on newline
        if text == "\n" {
            let difference = textView.frame.height - lastTextViewHeight
            if difference != 0 {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                                       bottom: lastKeyboardFrame!.height + difference + 20,
                                                       right: 0)
            }
            lastTextViewHeight = textView.frame.height
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeInput = nil
        
        // Handle placeholder text
        if textView.text.isEmpty {
            textView.text = "No notes"
            textView.textColor = UIColorCollection.placeHolderGrey
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let trigger = activeInput as? PickerTextField else {
            print("Active input not a PickerView!")
            return 0
        }
        
        switch trigger.pickerOptions {
        case .gender:
            return options.genderList.count
        case .diagnosis:
            return options.diagnosisList.count
        case .dosage:
            return options.dosageList.count
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let trigger = activeInput as? PickerTextField else {
            print("Active input not a PickerView!")
            return nil
        }
        
        switch trigger.pickerOptions {
        case .gender:
            return options.genderList[row]
        case .diagnosis:
            return options.diagnosisList[row]
        case .dosage:
            return options.dosageList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let trigger = activeInput as? PickerTextField else {
            print("Active input not a PickerView!")
            return
        }
        
        switch trigger.pickerOptions {
        case .gender:
            trigger.text = options.genderList[row]
        case .diagnosis:
            trigger.text = options.diagnosisList[row]
        case .dosage:
            trigger.text = options.dosageList[row]
        }
    }
    
    // MARK: - UIDataTableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = TableSection(rawValue: section) {
            switch currentSection {
            case .diagnosis:
                return diagnoses.count
            case .prescription:
                return prescriptions.count
            default:
                fatalError("Invalid table section!")
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentSection = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid section for row!")
        }
        
        switch currentSection {
        case .diagnosis:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiagnosisCell", for: indexPath) as? DiagnosisCell else {
                fatalError("Invalid DiagnosisCell!")
            }
            
            // Configure TextField for PickerView
            cell.diagnosisTextField.delegate = self
            cell.diagnosisTextField.inputView = pickerView
            cell.diagnosisTextField.pickerOptions = .diagnosis
            
            return cell
        case .prescription:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as? PrescriptionCell else {
                fatalError("Invalid PrescriptionCell!")
            }
            
            // Customize SearchTextField
            cell.prescriptionTextField.filterStrings(options.medicationList)
            cell.prescriptionTextField.theme.font = UIFont.systemFont(ofSize: 18)
            cell.prescriptionTextField.maxNumberOfResults = 5
            cell.prescriptionTextField.theme.bgColor = UIColor.white
            cell.prescriptionTextField.itemSelectionHandler = { filteredResults, itemPosition in
                let item = filteredResults[itemPosition]
                cell.prescriptionTextField.text = item.title
                cell.prescriptionTextField.resignFirstResponder()
            }
            
            // Configure TextFields for PickerView
            cell.dosageTextField.delegate = self
            cell.dosageTextField.inputView = pickerView
            cell.dosageTextField.pickerOptions = .dosage
            cell.quantityTextField.delegate = self
            
            return cell
        default:
            fatalError("Invalid section!")
        }
    }
    
    // MARK: - UIDataTableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerCell = tableView.dequeueReusableCell(withIdentifier: "FooterCell") as? FooterCell else {
            fatalError("Invalid FooterCell!")
        }
        
        if let currentSection = TableSection(rawValue: section) {
            switch currentSection {
            case .diagnosis:
                footerCell.additionLabel.text = "add diagnosis"
            case .prescription:
                footerCell.additionLabel.text = "add prescription"
            default:
                fatalError("Invalid table section!")
            }
        }
        
        // Add gesture recognizer to footer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.footerTapped(_:)))
        footerCell.addGestureRecognizer(gestureRecognizer)
        
        // Add drop shadow to plus button
        footerCell.plusImage.layer.shadowColor = UIColor.black.cgColor
        footerCell.plusImage.layer.shadowOffset = CGSize(width: 0, height: 1)
        footerCell.plusImage.layer.shadowOpacity = 0.1
        footerCell.plusImage.layer.shadowRadius = 0.8
        
        return footerCell
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let age = Int(ageTextField.text?.components(separatedBy: " ")[0] ?? "1")
        let clinicName = clinicTextField.text
        let creationDate = Date()
        let delete = false
        let diagnosis = ""
        let dosage = ""
        let gender = genderTextField.text
        let id = (((segue.destination as? DataTableController)?.patients.count)!) + 1
        let medication = ""
        let notes = notesTextView.text
        let provider = providerTextField.text
        
        // Core Data setup
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Patient", in: managedContext)!
        patient = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the patient to be passed to MealTableViewController after the unwind segue.
        patient?.setValue(age, forKeyPath: "age")
        patient?.setValue(clinicName, forKeyPath: "clinic")
        patient?.setValue(creationDate, forKeyPath: "creation")
        patient?.setValue(delete, forKeyPath: "delete")
        patient?.setValue(diagnosis, forKeyPath: "diagnosis")
        patient?.setValue(dosage, forKeyPath: "dosage")
        patient?.setValue(gender, forKeyPath: "gender")
        patient?.setValue(id, forKeyPath: "id")
        patient?.setValue(medication, forKeyPath: "medication")
        patient?.setValue(notes, forKeyPath: "notes")
        patient?.setValue(provider, forKeyPath: "provider")
        
        // Save to disk
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
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
        lastKeyboardFrame = keyboardRect
        
        var difference: CGFloat = 0
        
        if case let textView as UITextView = activeInput {
            // Calculate the difference between bottom of active TextView and top of keyboard
            guard let viewOrigin = textView.superview?.convert(textView.frame.origin, to: nil) else {
                return
            }
            // Difference + borderedStackView bottom margins set in IB
            let bottomFieldY = viewOrigin.y + textView.frame.height
            difference = bottomFieldY - keyboardRect.minY + 20
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
            difference = bottomFieldY - keyboardRect.minY
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
        // Reset content insets
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    @objc private func footerTapped(_ sender: UITapGestureRecognizer) {
        print("tapped!")
    }
}
