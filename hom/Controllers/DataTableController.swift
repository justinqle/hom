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

class DataTableController: UITableViewController, UISearchResultsUpdating, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>!
    
    enum Sorting: String {
        case mostRecent = "recent"
        case oldest = "oldest"
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Patients"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Setup default sorting
        let sorting = Sorting(rawValue: UserDefaults.standard.string(forKey: "sorting")!)!
        initializeFetchedResultsController(sorting: sorting)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
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
        cell.patientID.text = "Patient " + String(patient.value(forKey: Options.PatientKeys.id.rawValue) as! Int)
        
        // Clinic Name
        cell.clinicName.text = patient.value(forKey: Options.PatientKeys.clinic.rawValue) as? String
        
        // Addition Date
        let date = patient.value(forKey: Options.PatientKeys.creation.rawValue) as! Date
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
        let sexValue = NSMutableAttributedString(string: patient.value(forKey: Options.PatientKeys.sex.rawValue) as! String)
        sex.append(sexValue)
        let sexRange = (sex.string as NSString).range(of: "Sex: ")
        sex.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColorCollection.greyDarker, range: sexRange)
        cell.gender.attributedText = sex
        
        // Age label attributes
        let age = NSMutableAttributedString(string: "Age: ", attributes: [NSAttributedString.Key.font: mediumFont])
        let ageValue = NSMutableAttributedString(string: String(patient.value(forKey: Options.PatientKeys.age.rawValue) as! Int) + " year(s) old")
        age.append(ageValue)
        let ageRange = (age.string as NSString).range(of: "Age: ")
        age.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColorCollection.greyDarker, range: ageRange)
        cell.age.attributedText = age
        
        // Diagnoses
        let diagnoses = patient.value(forKey: Options.PatientKeys.diagnoses.rawValue) as! [String]
        cell.diagnosesCount.text = "Diagnoses (\(diagnoses.count))"
        cell.diagnoses.text = diagnoses.joined(separator: ", ")
        
        // Prescriptions
        let prescriptions = patient.value(forKey: Options.PatientKeys.prescriptions.rawValue) as! [Prescription]
        cell.prescriptionCount.text = "Prescriptions (\(prescriptions.count))"
        var medicines = [String]()
        for prescription in prescriptions {
            medicines.append(prescription.medicine)
        }
        cell.prescriptions.text = medicines.joined(separator: ", ")
        
        return cell
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        // Show all patients if search bar is empty
        if searchBarIsEmpty() {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        // Show patients filtered by search text
        else {
            let searchText = searchController.searchBar.text!
            
            // Fields to search
            let predicateClinic = NSPredicate(format: "clinic BEGINSWITH[c] %@", searchText)
            let predicateSex = NSPredicate(format: "sex BEGINSWITH[c] %@", searchText)
            let predicateAge = NSPredicate(format: "age BEGINSWITH[c] %@", searchText)
            
            // If any of the predicates match
            let orPredicate = NSCompoundPredicate(type: .or, subpredicates: [predicateClinic, predicateSex, predicateAge])
            
            fetchedResultsController.fetchRequest.predicate = orPredicate
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("FetchedResultsController failed to fetch: \(error)")
        }
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
        @unknown default:
            fatalError()
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
            
            entryAdditionController.id = UserDefaults.standard.integer(forKey: "RowCount") + 1
            
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
        
        // Sort by most recent
        alert.addAction(UIAlertAction(title: "Most Recent", style: .default, handler: { _ in
            self.initializeFetchedResultsController(sorting: Sorting.mostRecent)
            self.tableView.reloadData()
            UserDefaults.standard.set(Sorting.mostRecent.rawValue, forKey: "sorting")
        }))
        // Sort by oldest
        alert.addAction(UIAlertAction(title: "Oldest", style: .default, handler: { _ in
            self.initializeFetchedResultsController(sorting: Sorting.oldest)
            self.tableView.reloadData()
            UserDefaults.standard.set(Sorting.oldest.rawValue, forKey: "sorting")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func initializeFetchedResultsController(sorting: Sorting) {
        // Set up Core Data stack
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let moc = appDelegate.persistentContainer.viewContext
        
        // Create request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Patient")
        
        // Customize request based on sorting preferences
        if sorting == Sorting.mostRecent {
            let dateSort = NSSortDescriptor(key: "creation", ascending: false)
            request.sortDescriptors = [dateSort]
        } else if sorting == Sorting.oldest {
            let dateSort = NSSortDescriptor(key: "creation", ascending: true)
            request.sortDescriptors = [dateSort]
        }
        request.predicate = NSPredicate(format: "delete == %@", NSNumber(booleanLiteral: false))
        
        // Create fetched results controller from customized fetch request
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
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
}
