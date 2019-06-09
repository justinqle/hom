//
//  SettingsViewController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var providerTextField: InsetTextField!
    @IBOutlet weak var itemStackView: BorderedStackView!
    @IBOutlet weak var devInfoItem: UIView!
    @IBOutlet weak var devInfoStackView: BorderedStackView!
    @IBOutlet weak var attrInfoItem: UIView!
    @IBOutlet weak var attrInfoStackView: BorderedStackView!
    @IBOutlet weak var clearButton: UIButton!
    
    // MARK: - Overriden Functions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = contentView.frame.size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign delegates
        providerTextField.delegate = self
        
        // Border colors
        providerTextField.layer.borderColor = UIColorCollection.greyDark.cgColor
        providerTextField.layer.borderWidth = 1
        
        itemStackView.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        devInfoStackView.updateBorders(color: UIColorCollection.greyDark, borderThickness: 1)
        
        clearButton.layer.borderColor = UIColorCollection.greyDark.cgColor
        clearButton.layer.borderWidth = 1
        
        // Display ProviderName
        providerTextField.text = UserDefaults.standard.string(forKey: "ProviderName")
        
        // Add gesture recognizers
        let devTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        devTapRecognizer.minimumPressDuration = 0
        devInfoItem.addGestureRecognizer(devTapRecognizer)
        
        let attrTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        attrTapRecognizer.minimumPressDuration = 0
        attrInfoItem.addGestureRecognizer(attrTapRecognizer)
        
        let clearTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        clearTapRecognizer.minimumPressDuration = 0
        clearButton.addGestureRecognizer(clearTapRecognizer)
        
        // Dismiss keyboard on view tap
        self.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Update the provider name
        let prevName = UserDefaults.standard.string(forKey: "ProviderName")!
        if textField.text != "" && textField.text != prevName {
            UserDefaults.standard.set(textField.text!, forKey: "ProviderName")
            UserDefaults.standard.set(true, forKey: "GenerateCSV")
        } else {
            textField.text = UserDefaults.standard.string(forKey: "ProviderName")
        }
    }
    
    // MARK: - Actions
    
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .began {
            // Animate the touch
            if sender.view == clearButton {
                UIView.animate(withDuration: 0.1, animations: {
                    sender.view!.backgroundColor = UIColorCollection.greyTap
                })
            } else {
                sender.view!.backgroundColor = UIColorCollection.greyTap
            }
        } else if sender.state == .ended {
            if sender.view!.bounds.contains(sender.location(ofTouch: 0, in: sender.view!)) {
                // Touch ended inside of view, perform action
                if sender.view!.isDescendant(of: itemStackView) {
                    // Move to correct view controller, undo animation
                    sender.view!.backgroundColor = UIColor.white
                    if sender.view! == devInfoItem {
                        performSegue(withIdentifier: "DevInfo", sender: self)
                    } else if sender.view! == attrInfoItem {
                        performSegue(withIdentifier: "AttrInfo", sender: self)
                    } else {
                        fatalError("Invalid sender!")
                    }
                } else if sender.view == clearButton {
                    // Undo animation
                    clearButton.backgroundColor = UIColor.white
                    
                    // Show confirmation
                    let alert = UIAlertController(title: "Delete dataset?", message: "This action can not be undone.", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        // Clear table
                        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
                        deleteRequest.resultType = .resultTypeObjectIDs
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appDelegate.persistentContainer.viewContext
                        do {
                            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                            let objectIDArray = result?.result as? [NSManagedObjectID]
                            let changes = [NSDeletedObjectsKey : objectIDArray]
                            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
                        } catch {
                            fatalError("Failed to perform batch update: \(error)")
                        }
                        
                        // Delete the CSV and reset keys
                        if let csvName = UserDefaults.standard.string(forKey: "CSVName") {
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let documentsURL = NSURL(fileURLWithPath: documentsPath)
                            let filePath = documentsURL.appendingPathComponent(csvName)!
                            do {
                                try FileManager.default.removeItem(atPath: filePath.path)
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                        
                        UserDefaults.standard.removeObject(forKey: "CSVName")
                        UserDefaults.standard.set(true, forKey: "GenerateCSV")
                        UserDefaults.standard.set(0, forKey: "RowCount")
                        UserDefaults.standard.set("---", forKey: "LatestEntry")
                    }))
                    
                    self.present(alert, animated: true)
                }
            } else {
                // Touch ended outside of view, undo animation
                if sender.view == clearButton {
                    UIView.animate(withDuration: 0.1, animations: {
                        sender.view!.backgroundColor = UIColor.white
                    })
                } else {
                    sender.view!.backgroundColor = UIColor.white
                }
            }
        }
    }
}
