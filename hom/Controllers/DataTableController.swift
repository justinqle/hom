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

class DataTableController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>!
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ascending = UserDefaults.standard.bool(forKey: "ascending")
        initializeFetchedResultsController(ascending: ascending)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? DataTableCell else {
            fatalError("The dequeued cell is not an instance of DataTableCell.")
        }
        
        // Get patient at specified index
        guard let patient = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    // When Core Data gets changed, these methods update the UITableView
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let id = segue.identifier!
        
        switch(id) {
            
        case "AddItem":
            os_log("Adding a new patient.", log: OSLog.default, type: .debug)
            guard let destinationNavController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let entryAdditionController = destinationNavController.topViewController as? EntryAdditionController else {
                fatalError("Unexpected top view controller: \(String(describing: destinationNavController.topViewController))")
            }
            
            entryAdditionController.id = totalSize() + 1
            
        case "EditItem":
            os_log("Editing a patient.", log: OSLog.default, type: .debug)
            guard let entryAdditionController = segue.destination as? EntryAdditionController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // EntryAdditionController configuration for editing a patient
            entryAdditionController.navigationItem.title = "Edit Entry"
            entryAdditionController.navigationItem.largeTitleDisplayMode = .never
            entryAdditionController.navigationItem.setLeftBarButton(nil, animated: true)
            
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedObject = fetchedResultsController.object(at: indexPath) 
            entryAdditionController.patient = selectedObject
            
        default:
            fatalError("Unexpected Segue Identifier: \(id)")
        }
    }
    
    // MARK - Actions
    
    @IBAction func unwindToDataTable(sender: UIStoryboardSegue) {
        
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Sort by...", message: nil, preferredStyle: .actionSheet)
        
        // Sort by ascending ID order
        alert.addAction(UIAlertAction(title: "Ascending", style: .default, handler: { _ in
            self.initializeFetchedResultsController(ascending: true)
            self.tableView.reloadData()
            UserDefaults.standard.set(true, forKey: "ascending")
        }))
        // Sort by descending ID order
        alert.addAction(UIAlertAction(title: "Descending", style: .default, handler: { _ in
            self.initializeFetchedResultsController(ascending: false)
            self.tableView.reloadData()
            UserDefaults.standard.set(false, forKey: "ascending")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func initializeFetchedResultsController(ascending: Bool) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        let idSort = NSSortDescriptor(key: "id", ascending: ascending)
        request.sortDescriptors = [idSort]
        request.predicate = NSPredicate(format: "delete == %@", NSNumber(booleanLiteral: false))
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let moc = appDelegate.persistentContainer.viewContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // Gets total number of patients saved (including deletes)
    private func totalSize() -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Failed to get AppDelegate.")
        }
        let moc = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        
        do {
            let fetchedPatients = try moc.fetch(request)
            return fetchedPatients.count
        } catch {
            fatalError("Failed to fetch patients: \(error)")
        }
    }
}
