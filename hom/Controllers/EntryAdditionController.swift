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
    @IBOutlet weak var genderTextField: UITextField!
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
    private let sectionHeaderHeight: CGFloat = 25
    
    private enum TableSection: Int {
        case diagnosis = 0, prescription, total
    }
    
    private struct Prescription {
        var medicine: String
        var dosage: String
        var quantity: Int
    }
    
    private var tableData = [TableSection: [Any]]()
    
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
        
        tableData[.diagnosis] = ["GERD", "Headache"]
        tableData[.prescription]?.append(Prescription(medicine: "Gas-X", dosage: "1 week", quantity: 2))
        tableData[.prescription]?.append(Prescription(medicine: "Asprin 325mg", dosage: "1 month", quantity: 4))
        
        // Assign delegates
        clinicTextField.delegate = self
        genderTextField.delegate = self
        ageTextField.delegate = self
//        diagnosisTextField.delegate = self
//        prescriptionTextField.delegate = self
//        dosageTextField.delegate = self
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
        
        // Customize SearchTextField instance for prescriptions
//        prescriptionTextField.filterStrings(options.medicationList)
//        prescriptionTextField.theme.font = UIFont.systemFont(ofSize: 18)
//        prescriptionTextField.maxNumberOfResults = 5
//        prescriptionTextField.theme.bgColor = UIColor.white
//        prescriptionTextField.itemSelectionHandler = { filteredResults, itemPosition in
//            let item = filteredResults[itemPosition]
//            self.prescriptionTextField.text = item.title
//            self.prescriptionTextField.resignFirstResponder()
//        }
        
        // Customize TextFields for PickerView
        genderTextField.inputView = pickerView
//        diagnosisTextField.inputView = pickerView
//        dosageTextField.inputView = pickerView
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeInput = textField
        
        if textField == ageTextField {
            textField.text = ""
        } else if textField is PickerTextField {
            // Refresh the UIPickerField values if appropriate
            pickerView.reloadAllComponents()
            
            // Set default value for PickerTextField on input
            pickerView.selectRow(0, inComponent: 0, animated: true)
            switch textField {
            case genderTextField:
                textField.text = options.genderList[0]
//            case diagnosisTextField:
//                textField.text = options.diagnosisList[0]
//            case dosageTextField:
//                textField.text = options.dosageList[0]
            default:
                fatalError("Invalid picker trigger: \(textField)")
            }
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
        guard let trigger = activeInput else {
            print("Active input not set!")
            return 0
        }
        
        switch trigger {
        case genderTextField:
            return options.genderList.count
//        case diagnosisTextField:
//            return options.diagnosisList.count
//        case dosageTextField:
//            return options.dosageList.count
        default:
            print("Invalid picker trigger: \(trigger)")
            return 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let trigger = activeInput else {
            print("Active input not set!")
            return nil
        }
        
        switch trigger {
        case genderTextField:
            return options.genderList[row]
//        case diagnosisTextField:
//            return options.diagnosisList[row]
//        case dosageTextField:
//            return options.dosageList[row]
        default:
            print("Invalid picker trigger: \(trigger)")
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let trigger = activeInput as? UITextField else {
            print("Active input not set!")
            return
        }
        
        switch trigger {
        case genderTextField:
            trigger.text = options.genderList[row]
//        case diagnosisTextField:
//            trigger.text = options.diagnosisList[row]
//        case dosageTextField:
//            trigger.text = options.dosageList[row]
        default:
            print("Invalid picker trigger: \(trigger)")
        }
    }
    
    // MARK: - UIDataTableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection = TableSection(rawValue: section), let rows = tableData[currentSection] {
            return rows.count
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
            return cell
        case .prescription:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as? PrescriptionCell else {
                fatalError("Invalid PrescriptionCell!")
            }
            return cell
        default:
            fatalError("Invalid section!")
        }
    }
    
    // MARK: - UIDataTableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeaderHeight))
        view.layer.borderColor = UIColorCollection.greyDark.cgColor
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = #imageLiteral(resourceName: "PlusGreen")
        view.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 30, y: 0, width: tableView.bounds.width, height: sectionHeaderHeight))
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        if let currentSection = TableSection(rawValue: section) {
            switch currentSection {
            case .diagnosis:
                label.text = "add diagnosis"
            case .prescription:
                label.text = "add prescription"
            default:
                fatalError("Invalid table section!")
            }
        }
        view.addSubview(label)
        
        let gestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(self.footerTapped(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        return view
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
