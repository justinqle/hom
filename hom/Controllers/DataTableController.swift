//
//  DataTableController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "PatientCell"

class DataTableController: UITableViewController {
    
    // MARK: - Properties
    
    var patients: [NSManagedObject] = []
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        
        do {
            patients = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DataTableCell else {
            fatalError("The dequeued cell is not an instance of DataTableCell.")
        }
        
        // Fetches the appropriate patient for the data source layout.
        let patient = patients[indexPath.row]
        
        // TODO: Move optional-unwrapping to EntryAdditionController
        cell.patientID.text = "Patient " + String(patient.value(forKey: "id") as? Int ?? -1)
        cell.clinicName.text = patient.value(forKey: "clinic") as? String
        cell.creationDate.text = String((patient.value(forKey: "creation") as? Date ?? Date()).description)
        cell.age.text = String(patient.value(forKey: "age") as? Int ?? -1) + " years old"
        cell.diagnosis.text = (patient.value(forKeyPath: "diagnosis") as? String ?? "Error")
        cell.gender.text = (patient.value(forKey: "gender") as? String ?? "Error")
        cell.medication.text = (patient.value(forKey: "medication") as? String ?? "Error")
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToDataTable(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EntryAdditionController, let patient = sourceViewController.patient {
            if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                // Update an existing patient.
                patients[selectedIndexPath.row] = patient
                self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new patient.
                let newIndexPath = IndexPath(row: patients.count, section: 0)
                patients.append(patient)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
}
