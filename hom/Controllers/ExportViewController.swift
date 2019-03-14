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
        
        // Get full filepath
        let filePath = documentsURL.appendingPathComponent(nameTextField.text!)!
        
        // Attempt to use a previous CSV file of that name, or generate one if not found
        if !UserDefaults.standard.bool(forKey: "TableModifed") {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                generateCSV(atFullPath: filePath, docsDir: documentsURL as URL)
            }
        } else {
            generateCSV(atFullPath: filePath, docsDir: documentsURL as URL)
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
        
        // Create a new file at path
        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        if !FileManager.default.fileExists(atPath: path.path) {
            fatalError("Error creating file!")
        }
        
        var fetchOffset = 0
        let fetchLimit = 100
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        request.fetchLimit = fetchLimit
        request.fetchOffset = fetchOffset
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            // Create the column titles
            var csvString = "Date,Provider Name,Clinic Name,Patient Sex,Patient Age,Diagnosis 1,Diagnosis 2,Diagnosis 3,"
            csvString += "Presciption 1,Prescription 2,Prescription 3,Prescription 4,Prescription 5,"
            csvString += "Additional Notes\n"
            
            // Fetch the entries in batches and append them together
            let count = Double(try context.count(for: request))
            for _ in 0..<Int(ceil(count / Double(fetchLimit))) {
                let entries = try context.fetch(request)
                
                for entry in entries {
                    var entryString = ""
                    
                    // Get addition date
                    let entryDate = entry.value(forKey: "creation") as! Date
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM dd',' yyyy 'at' hh:mma"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"
                    let dateString = formatter.string(from: entryDate)
                    entryString += dateString + ","
                    
                    // Get Provider Name, Clinic Name, Sex, and Age
                    let providerName = UserDefaults.standard.string(forKey: "ProviderName")!
                    entryString += providerName + ","
                    
                    let clinicName = entry.value(forKey: "clinic") as! String
                    entryString += clinicName + ","
                    
                    let patientSex = entry.value(forKey: "sex") as! String
                    entryString += patientSex + ","
                    
                    let patientAge = String(entry.value(forKey: "age") as! Int)
                    entryString += patientAge + ","
                    
                    // Get max 3 diagnoses
                    let diagnoses = entry.value(forKey: "diagnoses") as! [String]
                    for diagnosis in diagnoses {
                        entryString += diagnosis + ","
                    }
                    
                    // Add empty values for any remaining diagnosis columns
                    if diagnoses.count < 3 {
                        for _ in 0..<(3 - diagnoses.count) {
                            entryString += ","
                        }
                    }
                    
                    // Get max 5 prescriptions
                    let prescriptions = entry.value(forKey: "prescriptions") as! [Prescription]
                    for presc in prescriptions {
                        let medicine = presc.medicine
                        let dosage = presc.dosage
                        let quantity = presc.quantity
                        entryString += medicine + " | "
                        entryString += dosage + " | "
                        entryString += String(quantity) + ","
                    }
                    
                    // Add empty values for any remaining prescription columns
                    if prescriptions.count < 5 {
                        for _ in 0..<(5 - prescriptions.count) {
                            entryString += ","
                        }
                    }
                    
                    // Get any additional notes
                    let notes = entry.value(forKey: "notes") as! String
                    entryString += notes + ","
                    
                    // End entry
                    entryString += "\n"
                    
                    // Append to full string
                    csvString += entryString
                }
                
                // Set new offset
                let newOffset = fetchOffset + fetchLimit
                request.fetchOffset = newOffset
                fetchOffset = newOffset
            }
            
            // Write to file
            try csvString.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            fatalError(error as! String)
        }
        
        // Delete any previous CSV files
        if let prevName = UserDefaults.standard.string(forKey: "CSVName") {
            let prevFilePath = docsDir.appendingPathComponent(prevName)
            if FileManager.default.fileExists(atPath: prevFilePath.path) {
                do {
                    try FileManager.default.removeItem(atPath: prevFilePath.path)
                } catch {
                    fatalError("Error deleting old file!")
                }
            }
        }
        
        // Save new filename for reuse
        UserDefaults.standard.set(nameTextField.text!, forKey: "CSVName")
    }
}
