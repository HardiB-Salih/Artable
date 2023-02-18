//
//  LoginVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 13.02.2023.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    

    @IBAction func loginBtnClicked(_ sender: Any) {
        guard let email = loginEmail.text , email.isNotEmpty,
              let password = loginPassword.text, password.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please fill out all fields.")
            return
        }
        
        self.progressBar.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { user , error in
            if let error = error {
                self.progressBar.stopAnimating()
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            
            self.progressBar.stopAnimating()
            self.dismiss(animated: true)
        }
        
        
    }
    
    @IBAction func forgotPasswordBtnClicked(_ sender: Any) {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func guestBtnClicked(_ sender: Any) {
//        self.progressBar.startAnimating()
//        Auth.auth().signInAnonymously { user, error in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//                return
//            }
//            
//            self.progressBar.stopAnimating()
//            self.dismiss(animated: true)
//        }
    }
    
    

}
