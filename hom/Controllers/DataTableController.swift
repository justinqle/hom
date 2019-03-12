//
//  DataTableController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit
import CoreData
import os.log

private let reuseIdentifier = "PatientCell"

class DataTableController: UITableViewController {
    
    // MARK: - Properties
    
    var patients: [NSManagedObject] = []
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DataTableCell else {
            fatalError("The dequeued cell is not an instance of DataTableCell.")
        }
        
        // Fetches the appropriate patient for the data source layout.
        let patient = patients[indexPath.row]
        
        // Patient ID
        cell.patientID.text = "Patient " + String(patient.value(forKey: "id") as! Int)
        
        // Clinic Name
        cell.clinicName.text = patient.value(forKey: "clinic") as? String
        
        // Addition Date
        let date = patient.value(forKey: "creation") as! Date
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/yy | hh:mma"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
        cell.creationDate.text = dateFormatter.string(from: date)
        
        // Sex label attributes
        let mediumFont = UIFont.systemFont(ofSize: 15, weight: .medium)
        let sex = NSMutableAttributedString(string: "Sex: ", attributes: [NSAttributedString.Key.font: mediumFont])
        let sexValue = NSMutableAttributedString(string: patient.value(forKey: "sex") as! String)
        sex.append(sexValue)
        let sexRange = (sex.string as NSString).range(of: "Sex: ")
        sex.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColorCollection.greyDarker, range: sexRange)
        cell.gender.attributedText = sex
        
        // Age label attributes
        let age = NSMutableAttributedString(string: "Age: ", attributes: [NSAttributedString.Key.font: mediumFont])
        let ageValue = NSMutableAttributedString(string: String(patient.value(forKey: "age") as! Int) + " years old")
        age.append(ageValue)
        let ageRange = (age.string as NSString).range(of: "Age: ")
        age.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColorCollection.greyDarker, range: ageRange)
        cell.age.attributedText = age
        
        // Diagnoses
        let diagnoses = patient.value(forKey: "diagnoses") as! [String]
        cell.diagnosesCount.text = "Diagnoses (\(diagnoses.count))"
        cell.diagnoses.text = diagnoses.joined(separator: ", ")
        
        // Prescriptions
        let prescriptions = patient.value(forKey: "prescriptions") as! [Prescription]
        cell.prescriptionCount.text = "Prescriptions (\(prescriptions.count))"
        var medicines = [String]()
        for prescription in prescriptions {
            medicines.append(prescription.medicine)
        }
        cell.prescriptions.text = medicines.joined(separator: ", ")
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let id = segue.identifier!
        
        switch(id) {
            
        case "AddItem":
            os_log("Adding a new patient.", log: OSLog.default, type: .debug)
            
        case "EditItem":
            guard let entryAdditionController = segue.destination as? EntryAdditionController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedCell = sender as? DataTableCell else {
                fatalError("Unexpected sender: \(sender!)")
            }
            guard let indexPath = tableView.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // EntryAdditionController configuration for editing a patient
            entryAdditionController.navigationItem.title = "Edit Entry"
            entryAdditionController.navigationItem.largeTitleDisplayMode = .never
            entryAdditionController.navigationItem.setLeftBarButton(nil, animated: true)
            
            let selectedPatient = patients[indexPath.row]
            entryAdditionController.patient = selectedPatient
            
        default:
            fatalError("Unexpected Segue Identifier: \(id)")
            
        }
    }
    
    // MARK - Actions
    
    @IBAction func unwindToDataTable(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EntryAdditionController, let patient = sourceViewController.patient {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing patient.
                patients[selectedIndexPath.row] = patient
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new patient.
                let newIndexPath = IndexPath(row: patients.count, section: 0)
                patients.append(patient)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort by...", message: nil, preferredStyle: .actionSheet)
        
        // Sort by ascending ID order
        alert.addAction(UIAlertAction(title: "Ascending", style: .default, handler: { _ in
            self.patients.sort() { ($0.value(forKey: "id") as! Int) < ($1.value(forKey: "id") as! Int) }
            self.tableView.reloadData()
        }))
        // Sort by descending ID order
        alert.addAction(UIAlertAction(title: "Descending", style: .default, handler: { _ in
            self.patients.sort() { ($0.value(forKey: "id") as! Int) > ($1.value(forKey: "id") as! Int) }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Public Methods
    
    public func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        
        do {
            patients = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch: \(error), \(error.userInfo)")
        }
    }
}
