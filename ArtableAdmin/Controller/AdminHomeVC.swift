//
//  ViewController.swift
//  ArtableAdmin
//
//  Created by Hardi B. Salih on 12.02.2023.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.leftBarButtonItem?.isEnabled = false
        
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
    }
    
    @objc func addCategory() {
        performSegue(withIdentifier: Segues.ToAddEditCategory, sender: self)
    }


}

