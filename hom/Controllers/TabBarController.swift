//
//  TabBarController.swift
//  hom
//
//  Created by Dean  Foster on 3/22/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private var tableController: DataTableController!
    private var prevItemTitle: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        tableController = ((viewControllers![0] as! UINavigationController).viewControllers.first as! DataTableController)
        prevItemTitle = "Table"
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if prevItemTitle == "Table" && item.title == "Table" && tableController.tableView.numberOfRows(inSection: 0) > 0 {
            tableController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        prevItemTitle = item.title!
    }
}
