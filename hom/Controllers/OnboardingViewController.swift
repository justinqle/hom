//
//  OnboardingViewController.swift
//  hom
//
//  Created by Dean  Foster on 3/6/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit
import CoreData

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
        
        // Generate dummy data
//        createDummyData(entryCount: 850)
        
        // Save Provider Name during segue
        UserDefaults.standard.set(providerTextField.text!, forKey: "ProviderName")
        
        // Set defaults for other keys
        UserDefaults.standard.set(true, forKey: "GenerateCSV")
        UserDefaults.standard.set(DataTableController.Sorting.mostRecent.rawValue, forKey: "sorting")
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
    
    private func createDummyData(entryCount: Int) {
        
        UserDefaults.standard.set(entryCount, forKey: "RowCount")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let clinicNames = ["Marigot", "\"Hope for Haiti\"", "Hope, for Haiti", "\"Hope,\" for Haiti", "Marigot! \"Wow, that's cool\""]
        let notesList = ["", "Need more meds.", "We're all good here!", "Need some more of those...\n\"meds\".", "Wow, we're doing \n\nwell!"]
        
        for index in 1...entryCount {
            // Generate random values
            let deleted = [true, false].randomElement()!
            let creationDate = Date()
            let clinicName = clinicNames.randomElement()!
            let patientID = index
            let patientSex = ["Male", "Female"].randomElement()!
            let patientAge = Int.random(in: 0...100)
            
            var diagnoses = [String]()
            let diagnosisCount = Int.random(in: 1...3)
            for _ in 0..<diagnosisCount {
                diagnoses.append(Options.shared.diagnosisList.randomElement()!)
            }
            
            var prescriptions = [Prescription]()
            let prescriptionCount = Int.random(in: 1...5)
            for _ in 0..<prescriptionCount {
                let medication = Options.shared.medicationList.randomElement()!
                let dosage = Options.shared.dosageList.randomElement()!
                let quantity = Options.shared.quantityList.randomElement()!
                prescriptions.append(Prescription(medicine: medication, dosage: dosage, quantity: quantity))
            }
            
            let notes = notesList.randomElement()!
            
            let dpString = diagnoses.joined() + prescriptions.map{$0.medicine}.joined()
            
            // Set values
            let entity = NSEntityDescription.entity(forEntityName: "Patient", in: context)!
            let patient = NSManagedObject(entity: entity, insertInto: context)
            patient.setValue(deleted, forKey: Options.PatientKeys.deleted.rawValue)
            patient.setValue(creationDate, forKey: Options.PatientKeys.creation.rawValue)
            patient.setValue(clinicName, forKey: Options.PatientKeys.clinic.rawValue)
            patient.setValue(patientID, forKey: Options.PatientKeys.id.rawValue)
            patient.setValue(patientSex, forKey: Options.PatientKeys.sex.rawValue)
            patient.setValue(patientAge, forKey: Options.PatientKeys.age.rawValue)
            patient.setValue(diagnoses, forKey: Options.PatientKeys.diagnoses.rawValue)
            patient.setValue(prescriptions, forKey: Options.PatientKeys.prescriptions.rawValue)
            patient.setValue(notes, forKey: Options.PatientKeys.notes.rawValue)
            patient.setValue(dpString, forKey: Options.PatientKeys.dpString.rawValue)
            
            // Store to data model
            do {
                try context.save()
                print("Entry created: \(patient)")
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
