//
//  ExportViewController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CSV

class ExportViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var rowLabel: UILabel!
    @IBOutlet weak var latestEntryLabel: UILabel!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update view values
        providerLabel.text = UserDefaults.standard.string(forKey: "ProviderName")
        rowLabel.text = String(UserDefaults.standard.integer(forKey: "RowCount"))
        if let latestEntry = UserDefaults.standard.string(forKey: "LatestEntry") {
            latestEntryLabel.text = latestEntry
        }
        if let prevFileName = UserDefaults.standard.string(forKey: "CSVName") {
            if nameTextField.text == "" {
                nameTextField.text = prevFileName
                exportButton.isEnabled = true
                exportButton.backgroundColor = UIColorCollection.accentOrange
                exportButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
            }
        }
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
        
        // Get documents directory
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = NSURL(fileURLWithPath: documentsPath)
        
        // Create filepath to CSV
        let filePath = documentsURL.appendingPathComponent(nameTextField.text!)!
        
        // Determine whether to generate new CSV or rename the previous one
        let shouldGenerate = UserDefaults.standard.bool(forKey: "GenerateCSV")
        if shouldGenerate {
            // Generate new CSV if table was modified
            generateCSV(atFullPath: filePath, docsDir: documentsURL as URL)
            
            // Save new filename for reuse, toggle modification status
            UserDefaults.standard.set(nameTextField.text!, forKey: "CSVName")
            UserDefaults.standard.set(false, forKey: "GenerateCSV")
        } else {
            if let prevCSV = UserDefaults.standard.string(forKey: "CSVName") {
                if prevCSV != nameTextField.text! {
                    // Rename the file to the new name
                    do {
                        let oldFileURL = documentsURL.appendingPathComponent(prevCSV)!
                        let newFileURL = documentsURL.appendingPathComponent(nameTextField.text!)!
                        try FileManager.default.moveItem(at: oldFileURL, to: newFileURL)
                        UserDefaults.standard.set(nameTextField.text!, forKey: "CSVName")
                    } catch {
                        fatalError(error as! String)
                    }
                }
            }
        }
        
        // Share the file
        let objectsToShare = [filePath]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.assignToContact,
                                                        UIActivity.ActivityType.saveToCameraRoll,
                                                        UIActivity.ActivityType.postToFlickr,
                                                        UIActivity.ActivityType.postToVimeo,
                                                        UIActivity.ActivityType.postToTencentWeibo,
                                                        UIActivity.ActivityType.postToTwitter,
                                                        UIActivity.ActivityType.postToFacebook,
                                                        UIActivity.ActivityType.openInIBooks]
        self.present(activityViewController, animated: true, completion: nil)
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
    
    private func generateCSV(atFullPath path: URL, docsDir: URL) {
        print("generating")
        
        // Clear any old CSVs in documents directory
        do {
            let oldFiles = try FileManager.default.contentsOfDirectory(atPath: docsDir.path)
            for file in oldFiles {
                print("deleting old file \(file)")
                try FileManager.default.removeItem(atPath: docsDir.path + "/" + file)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create a new file at path
        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        if !FileManager.default.fileExists(atPath: path.path) {
            fatalError("Error creating file!")
        }
        
        var fetchOffset = 0
        let fetchLimit = 100
        
        // Fetch data from model
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        
        // Get patients in ascending ID order for export
        let idSort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [idSort]
        
        request.fetchLimit = fetchLimit
        request.fetchOffset = fetchOffset
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            
            // Create the column titles
            var csvString = "Deleted,PatientID,Date,Provider Name,Clinic Name,Patient Sex,Patient Age,Diagnosis 1,Diagnosis 2,Diagnosis 3,"
            csvString += "Presciption 1,Prescription 2,Prescription 3,Prescription 4,Prescription 5,"
            csvString += "Additional Notes\n"
            
            // Fetch the entries in batches and append them together
            let count = Double(try context.count(for: request))
            for _ in 0..<Int(ceil(count / Double(fetchLimit))) {
                let entries = try context.fetch(request)
                
                for entry in entries {
                    // Get deletion status
                    let wasDeleted = entry.value(forKey: "delete") as! Bool
                    if wasDeleted {
                        csvString += "Yes,"
                    } else {
                        csvString += ","
                    }
                    
                    // Get patient ID
                    let patientID = String(entry.value(forKey: "id") as! Int)
                    csvString += patientID + ","
                    
                    // Get addition date
                    let entryDate = entry.value(forKey: "creation") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yy 'at' hh:mma"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"
                    let dateString = formatter.string(from: entryDate)
                    csvString += dateString + ","
                    
                    // Get Provider Name, Clinic Name, Sex, and Age
                    var providerName = UserDefaults.standard.string(forKey: "ProviderName")!
                    providerName = providerName.replacingOccurrences(of: "\"", with: "\"\"")
                    csvString += "\"\(providerName)\","
                    
                    var clinicName = entry.value(forKey: "clinic") as! String
                    clinicName = clinicName.replacingOccurrences(of: "\"", with: "\"\"")
                    csvString += "\"\(clinicName)\","
                    
                    let patientSex = entry.value(forKey: "sex") as! String
                    csvString += patientSex + ","
                    
                    let patientAge = String(entry.value(forKey: "age") as! Int)
                    csvString += patientAge + ","
                    
                    // Get max 3 diagnoses
                    let diagnoses = entry.value(forKey: "diagnoses") as! [String]
                    for diagnosis in diagnoses {
                        let augDiagnosis = diagnosis.replacingOccurrences(of: "\"", with: "\"\"")
                        csvString += "\"\(augDiagnosis)\","
                    }
                    
                    // Add empty values for any remaining diagnosis columns
                    if diagnoses.count < 3 {
                        for _ in 0..<(3 - diagnoses.count) {
                            csvString += ","
                        }
                    }
                    
                    // Get max 5 prescriptions
                    let prescriptions = entry.value(forKey: "prescriptions") as! [Prescription]
                    for presc in prescriptions {
                        let medicine = presc.medicine
                        let dosage = presc.dosage
                        let quantity = presc.quantity
                        let medicineString = medicine + " | "
                        let dosageString = dosage + " | "
                        let quantityString = String(quantity)
                        var fullEntry = "\(medicineString)\(dosageString)\(quantityString)"
                        fullEntry = fullEntry.replacingOccurrences(of: "\"", with: "\"\"")
                        csvString += "\"\(fullEntry)\","
                    }
                    
                    // Add empty values for any remaining prescription columns
                    if prescriptions.count < 5 {
                        for _ in 0..<(5 - prescriptions.count) {
                            csvString += ","
                        }
                    }
                    
                    // Get any additional notes
                    var notes = entry.value(forKey: "notes") as! String
                    notes = notes.replacingOccurrences(of: "\"", with: "\"\"")
                    csvString += "\"\(notes)\""
                    
                    // End row
                    csvString += "\n"
                }
                
                // Set new offset
                let newOffset = fetchOffset + fetchLimit
                request.fetchOffset = newOffset
                fetchOffset = newOffset
            }
            
            // Write to file
            try csvString.write(toFile: path.path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
