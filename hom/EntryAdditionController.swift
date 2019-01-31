//
//  EntryAdditionController.swift
//  hom
//
//  Created by Dean  Foster on 1/29/19.
//  Copyright © 2019 Heart of Medicine. All rights reserved.
//

import UIKit

class EntryAdditionController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = contentView.frame.size
        scrollView.delegate = self
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
