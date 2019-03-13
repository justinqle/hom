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

protocol UITableCellSubView {
    var parentCell: UITableViewCell? { get set }
}

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
    @IBOutlet weak var deleteButtonStack: UIStackView!
    @IBOutlet weak var deleteButtonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    enum TableSection: Int {
        case diagnosis = 0, prescription, total
    }
    
    private let options = Options.shared
    private var activeInput: UIView?
    private let pickerView = UIPickerView()
    private var additionDate: Date!
    private let sectionFooterHeight: CGFloat = 42
    private let sectionPadding: CGFloat = 15
    
    private var diagnoses = [String]() {
        didSet {
            // Enable or disable the footer
            if let footer = tableView.footerView(forSection: 0) {
                if diagnoses.count == 3 {
                    setFooterInteractable(footer, setEnabled: false)
                } else {
                    setFooterInteractable(footer, setEnabled: true)
                }
            }
        }
    }
    
    private var prescriptions = [Prescription]() {
        didSet {
            // Enable or disable the footer
            if let footer = tableView.footerView(forSection: 1) {
                if prescriptions.count == 5 {
                    setFooterInteractable(footer, setEnabled: false)
                } else {
                    setFooterInteractable(footer, setEnabled: true)
                }
            }
        }
    }
    
    // MARK: - Overriden Methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ScrollView content size
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        scrollView.delegate = self
        clinicTextField.delegate = self
        genderTextField.delegate = self
        ageTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        notesTextView.delegate = self
        pickerView.delegate = self
        
        // Fill in patient data if editing patient
        if let patient = patient {
            clinicTextField.text = patient.value(forKey: "clinic") as? String
            genderTextField.text = patient.value(forKey: "sex") as? String
            ageTextField.text = String(patient.value(forKey: "age") as! Int) + " years old"
            diagnoses = patient.value(forKey: "diagnoses") as! [String]
            prescriptions = patient.value(forKey: "prescriptions") as! [Prescription]
            notesTextView.text = patient.value(forKey: "notes") as? String
            additionDate = patient.value(forKey: "creation") as? Date
            
            // Show delete button
            deleteButtonStack.isHidden = false
        }
        else {
            additionDate = Date()
        }
        
        // Provider TextField borders
        providerTextField.layer.borderColor = UIColorCollection.greyDark.cgColor
        providerTextField.layer.borderWidth = 1
        
        // Form view container borders
        patientInfoView.layer.borderColor = UIColorCollection.greyDark.cgColor
        patientInfoView.layer.borderWidth = 1
        
        // Button view container borders
        deleteButtonView.layer.borderColor = UIColorCollection.greyDark.cgColor
        deleteButtonView.layer.borderWidth = 1
        
        // Customize GenderTextField input options
        genderTextField.inputView = pickerView
        genderTextField.pickerOptions = .gender
        
        // Configure UIPickerView
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        // Display and store current date and time
        let formatter = DateFormatter()
        formatter.dateFormat = "'Added' MMMM dd',' yyyy 'at' hh:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: additionDate)
        creationLabel.text = dateString
        
        UserDefaults.standard.set(dateString, forKey: "LatestEntry")
        
        // Display ProviderName
        providerTextField.text = UserDefaults.standard.string(forKey: "ProviderName")
        
        // Dismiss the keyboard on tap of the content
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        // Register observers for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        enableSaveButton();
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
            if let text = textField.text, text != "" {
                let age = text.components(separatedBy: " ")
                textField.text = age[0]
            }
        } else if textField is PickerTextField {
            // Set default value for PickerTextField on input
            let pickerTrigger = textField as! PickerTextField
            
            // Refresh the UIPickerField values
            pickerView.reloadAllComponents()

            // Assign default value or preserve previous one
            switch pickerTrigger.pickerOptions! {
            case .gender:
                if let text = pickerTrigger.text, text != "Not Chosen" {
                    if let index = options.genderList.firstIndex(of: text) {
                        pickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                } else {
                    pickerTrigger.text = options.genderList[0]
                    pickerView.selectRow(0, inComponent: 0, animated: true)
                }
            case .diagnosis:
                if let text = pickerTrigger.text, text != "Not Chosen" {
                    if let index = options.diagnosisList.firstIndex(of: text) {
                        pickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                } else {
                    pickerTrigger.text = options.diagnosisList[0]
                    pickerView.selectRow(0, inComponent: 0, animated: true)
                }
            case .dosage:
                if let text = pickerTrigger.text, text != "" {
                    if let index = options.dosageList.firstIndex(of: text) {
                        pickerView.selectRow(index, inComponent: 0, animated: true)
                    }
                } else {
                    pickerTrigger.text = options.dosageList[0]
                    pickerView.selectRow(0, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeInput = nil
        
        if textField == ageTextField {
            if let text = textField.text {
                // Append "years old" and trim leading 0's
                if text != "" {
                    let integer = Int(text)!
                    let trimmed = String(integer)
                    let newText = trimmed + " years old"
                    textField.text = newText
                }
            }
        } else if textField is PickerTextField {
            // Re-enable user interaction
            textField.isUserInteractionEnabled = true
        } else if textField is InsetTextField, (textField as! UITableCellSubView).parentCell != nil {
            // Trim leading excess 0's from the quantity field
            if let text = textField.text, text != "" {
                let integer = Int(text)!
                let trimmed = String(integer)
                textField.text = trimmed
            }
        }
        
        // Update values in the appropriate data model if field is contained in the table
        if let cellField = textField as? UITableCellSubView, cellField.parentCell != nil {
            switch TableSection(rawValue: tableView.indexPath(for: cellField.parentCell!)!.section)! {
            case .diagnosis:
                diagnoses[tableView.indexPath(for: cellField.parentCell!)!.row] = textField.text ?? ""
            case .prescription:
                switch textField {
                case textField as? SearchTextField:
                    prescriptions[tableView.indexPath(for: cellField.parentCell!)!.row].medicine = textField.text ?? ""
                case textField as? PickerTextField:
                    prescriptions[tableView.indexPath(for: cellField.parentCell!)!.row].dosage = textField.text ?? ""
                case textField as? InsetTextField:
                    var text = textField.text ?? "0"
                    if text == "" {
                        text = "0"
                    }
                    prescriptions[tableView.indexPath(for: cellField.parentCell!)!.row].quantity = Int(text)!
                default:
                    fatalError("Invalid CellSubView!")
                }
            case .total:
                fatalError("Invalid TableSection assigned!")
            }
        }
        
        enableSaveButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeInput = textView
        
        // Handle placeholder text
        if textView.textColor == UIColorCollection.greyDark {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        activeInput = nil
        
        // Handle placeholder text
        if textView.text.isEmpty {
            textView.text = "No notes"
            textView.textColor = UIColorCollection.greyDark
        }
        
        enableSaveButton()
        return true
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
        
        switch trigger.pickerOptions! {
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
        
        switch trigger.pickerOptions! {
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
        
        // Set the appropriate value
        switch trigger.pickerOptions! {
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
            
            // Configure TextField
            cell.diagnosisTextField.delegate = self
            cell.diagnosisTextField.inputView = pickerView
            cell.diagnosisTextField.pickerOptions = .diagnosis
            
            // Assign a reference to row index in appropriate subviews
            cell.diagnosisTextField.parentCell = cell
            
            // Assign values in the data model if available
            let diagnosis = diagnoses[indexPath.row]
            if diagnosis != "" {
                cell.diagnosisTextField.text = diagnosis
            } else {
                cell.diagnosisTextField.text = "Not Chosen"
            }
            
            return cell
        case .prescription:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as? PrescriptionCell else {
                fatalError("Invalid PrescriptionCell!")
            }
            
            // Customize SearchTextField
            cell.prescriptionTextField.delegate = self
            cell.prescriptionTextField.filterStrings(options.medicationList)
            cell.prescriptionTextField.theme.font = UIFont.systemFont(ofSize: 18)
            cell.prescriptionTextField.maxNumberOfResults = 5
            cell.prescriptionTextField.theme.bgColor = UIColor.white
            cell.prescriptionTextField.itemSelectionHandler = { filteredResults, itemPosition in
                let item = filteredResults[itemPosition]
                cell.prescriptionTextField.text = item.title
                cell.prescriptionTextField.resignFirstResponder()
            }
            
            // Configure TextFields
            cell.dosageTextField.delegate = self
            cell.dosageTextField.inputView = pickerView
            cell.dosageTextField.pickerOptions = .dosage
            cell.quantityTextField.delegate = self
            
            // Assign a reference to parent cell in appropriate subviews
            cell.prescriptionTextField.parentCell = cell
            cell.dosageTextField.parentCell = cell
            cell.quantityTextField.parentCell = cell
            
            // Assign values from the data model if available
            let medication = prescriptions[indexPath.row].medicine
            cell.prescriptionTextField.text = medication
            
            let dosage = prescriptions[indexPath.row].dosage
            cell.dosageTextField.text = dosage
            
            let quantity = prescriptions[indexPath.row].quantity
            if quantity != 0 {
                cell.quantityTextField.text = String(quantity)
            } else {
                cell.quantityTextField.text = ""
            }
            
            return cell
        default:
            fatalError("Invalid section!")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let tableSection = TableSection(rawValue: indexPath.section) else {
            fatalError("Invalid TableSection!")
        }
        
        if editingStyle == .delete {
            switch tableSection {
            case .diagnosis:
                // Remove cell from data model and table
                diagnoses.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .prescription:
                // Set PresciptionTextField text to "" to ensure menu does not appear when recycled
                guard let cell = tableView.cellForRow(at: indexPath) as? PrescriptionCell else {
                    fatalError("TableCell is not a PrescriptionCell!")
                }
                
                cell.prescriptionTextField.text = ""
                
                // Remove cell from data model and table
                prescriptions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .total:
                fatalError("Invalid TableSection!")
            }
        }
        
        enableSaveButton()
    }
    
    // MARK: - UIDataTableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight + sectionPadding
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Create footer parent
        let footer = AdditionFooter()
        
        // Create footer background view
        let footerBackground = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionFooterHeight + sectionPadding))
        footer.backgroundView = footerBackground
        
        // Create StackView
        let stackView = BorderedStackView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionFooterHeight))
        stackView.axis = .horizontal
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fill
        stackView.spacing = 16
        
        stackView.top = true
        stackView.bottom = true
        stackView.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        
        // Create a background view
        let stackViewBackground = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionFooterHeight))
        
        // Add plus "button"
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        image.tintColor = UIColorCollection.accentGreen
        image.image = #imageLiteral(resourceName: "PlusGreen")
        image.contentMode = .scaleAspectFit
        
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowOffset = CGSize(width: 0, height: 1)
        image.layer.shadowOpacity = 0.1
        image.layer.shadowRadius = 0.8
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        // Add label
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 25))
        
        // Set label text
        if let currentSection = TableSection(rawValue: section) {
            switch currentSection {
            case .diagnosis:
                label.text = "add diagnosis"
                label.sizeToFit()
                footer.parentSection = .diagnosis
            case .prescription:
                label.text = "add prescription"
                label.sizeToFit()
                footer.parentSection = .prescription
            default:
                fatalError("Invalid table section!")
            }
        }

        // Add gesture recognizer to footer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.footerTapped(_:)))
        stackView.addGestureRecognizer(gestureRecognizer)
        
        // Add subviews
        footer.contentView.addSubview(stackViewBackground)
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(label)
        footer.contentView.addSubview(stackView)

        return footer
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let age = Int(ageTextField.text!.components(separatedBy: " ")[0])!
        let clinicName = clinicTextField.text!
        let creationDate = additionDate
        let delete = false
        let id = (((segue.destination as? DataTableController)?.patients.count)!) + 1
        let notes = notesTextView.text
        let sex = genderTextField.text!
        
        // Core Data setup
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Patient", in: managedContext)!
        patient = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // Set the patient to be passed to DataTableController after the unwind segue.
        patient?.setValue(age, forKeyPath: "age")
        patient?.setValue(clinicName, forKeyPath: "clinic")
        patient?.setValue(creationDate, forKeyPath: "creation")
        patient?.setValue(delete, forKeyPath: "delete")
        patient?.setValue(diagnoses, forKeyPath: "diagnoses")
        patient?.setValue(id, forKeyPath: "id")
        patient?.setValue(notes, forKeyPath: "notes")
        patient?.setValue(prescriptions, forKeyPath: "prescriptions")
        patient?.setValue(sex, forKeyPath: "sex")
        
        // Save to disk
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteTouchUpInside(_ sender: Any) {
        
    }
    
    // MARK: - Private Methods
    
    // Enables save button if all required fields are filled out
    private func enableSaveButton() {
        var validDiagnoses = true
        if diagnoses.isEmpty {
            validDiagnoses = false
        } else {
            for diagnosis in diagnoses {
                if diagnosis == "" {
                    validDiagnoses = false
                    break;
                }
            }
        }
        
        var validPrescriptions = true
        if prescriptions.isEmpty {
            validPrescriptions = false
        } else {
            for prescription in prescriptions {
                if prescription.medicine == "" || prescription.dosage == "" || prescription.quantity == 0 {
                    validDiagnoses = false
                    break;
                }
            }
        }
        
        let validFields = !clinicTextField.text!.isEmpty && genderTextField.text != "Not Chosen"
            && !ageTextField.text!.isEmpty && validDiagnoses && validPrescriptions
        
        if validFields {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @objc private func keyboardWillChange(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardWillChangeFrameNotification {
            
            guard var input = activeInput else {
                return
            }
            
            // Set edge insets to account for keyboard
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height, right: 0)
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
            
            // Find the part of the screen that is visible
            var rect = self.view.frame
            rect.size.height -= keyboardRect.height
            
            // Does the active input have a superview with margins?
            if let superview = input.superview as? UIStackView {
                input = superview
            }
            
            // Find the bottom edge of the active view
            let bottom = CGPoint(x: 0, y: input.frame.maxY)
            
            // Scroll if the active input is not visible
            if !rect.contains(bottom) {
                scrollView.scrollRectToVisible(input.frame, animated: true)
            }
            
        } else {
            // Reset the insets
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
    }
    
    @objc private func footerTapped(_ sender: UITapGestureRecognizer) {
        guard let sendingFooter = sender.view?.superview?.superview as? AdditionFooter else {
            fatalError("Tap did not come from a footer!")
        }
        
        // Hide keyboard if needed
        view.endEditing(true)

        // Animate tap
        let footerBackground = sendingFooter.contentView.subviews[0]
        UIView.animate(withDuration: 0.08, animations: {
            footerBackground.backgroundColor = UIColorCollection.greyTap
        }, completion: {_ in
            // Append initial dummy data and insert new cell
            switch sendingFooter.parentSection {
            case .diagnosis:
                self.diagnoses.append("")
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: self.diagnoses.count - 1, section: 0)], with: .left)
                self.tableView.endUpdates()
            case .prescription:
                self.prescriptions.append(Prescription(medicine: "", dosage: "", quantity: 0))
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: self.prescriptions.count - 1, section: 1)], with: .left)
                self.tableView.endUpdates()
            case .total:
                fatalError("Invalid table section!")
            }

            // Undo animation
            UIView.animate(withDuration: 0.2, animations: {
                footerBackground.backgroundColor = UIColor.white
            })
        })
        
        saveButton.isEnabled = false
    }
    
    private func setFooterInteractable(_ footer: UITableViewHeaderFooterView, setEnabled: Bool) {
        guard let stackView = footer.contentView.subviews[1] as? UIStackView else {
            fatalError("Child is not a StackView!")
        }
        
        guard let plus = stackView.subviews[0] as? UIImageView else {
            fatalError("Child is not an ImageView!")
        }
        
        guard let label = stackView.subviews[1] as? UILabel else {
            fatalError("Child is not a Label!")
        }
        
        if setEnabled {
            stackView.isUserInteractionEnabled = true
            plus.tintColor = UIColorCollection.accentGreen
            label.textColor = UIColor.black
        } else {
            stackView.isUserInteractionEnabled = false
            plus.tintColor = UIColorCollection.greyDark
            label.textColor = UIColorCollection.greyDarker
        }
    }
}
