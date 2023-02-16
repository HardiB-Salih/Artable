//
//  ViewController.swift
//  Artable
//
//  Created by Hardi B. Salih on 12.02.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storybord = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storybord.instantiateViewController(withIdentifier: StorybaordId.LoginVC)
        present(controller, animated: true)
    }


}

