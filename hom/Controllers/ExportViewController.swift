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
            nameTextField.text = prevFileName
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
        
        // Save filename for reuse
        UserDefaults.standard.set(nameTextField.text!, forKey: "CSVName")
        
        // Get documents directory
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = NSURL(fileURLWithPath: documentsPath)
        
        // Get full filepath
        let filePath = documentsURL.appendingPathComponent(nameTextField.text!)!
        
        // Attempt to use a previous CSV file of that name, or generate one if not found
        if !UserDefaults.standard.bool(forKey: "TableModifed") {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                generateCSV(atPath: filePath)
            }
        } else {
            generateCSV(atPath: filePath)
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
    
    private func generateCSV(atPath path: URL) {
        // Create a new file at path
        FileManager.default.createFile(atPath: path.path, contents: nil, attributes: nil)
        
        // Collect entries in batches and write to file
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        request.fetchLimit = 100
        request.fetchOffset = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let count = Double(try context.count(for: request))
            for _ in 0..<Int(ceil(count / 100.0)) {
                let entries = try context.fetch(request)
                
                // Format the entries
                for entry in entries {
                    
                }
            }
        }
        catch {
            print(error)
        }
        
        // Delete any previous CSV files of a different name
        
        
    }
}
