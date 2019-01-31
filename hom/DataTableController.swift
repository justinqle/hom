//
//  DataTableController.swift
//  hom
//
//  Created by Dean  Foster on 1/26/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class DataTableController: UITableViewController {
    
    // MARK: - Properties
    
    var patients: [NSManagedObject] = []
    
    // MARK: - Overriden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(DataTableCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let patient = patients[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = patient.value(forKeyPath: "diagnosis") as? String
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToDataTable(sender: UIStoryboardSegue) {
        
    }
    
}
