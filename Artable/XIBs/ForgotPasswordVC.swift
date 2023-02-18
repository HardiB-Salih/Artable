//
//  ForgotPasswordVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 16.02.2023.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    @IBOutlet weak var emailTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func cancelClicked(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        guard let email = emailTxt.text , email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please enter email.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

