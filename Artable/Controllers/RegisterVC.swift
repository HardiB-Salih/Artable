//
//  RegisterVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 13.02.2023.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    @IBOutlet weak var registerUserName: UITextField!
    @IBOutlet weak var registerEmail: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerPasswordConfig: UITextField!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    
    @IBOutlet weak var passwordCheckImg: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        registerPasswordConfig.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Here we can check when text changes
        guard let password = registerPassword.text else { return }
        
        //        show the check images
        if textField == registerPasswordConfig {
            passwordCheckImg.isHidden = false
            confirmPasswordCheckImg.isHidden = false
        } else {
            if password.isEmpty {
                passwordCheckImg.isHidden = true
                confirmPasswordCheckImg.isHidden = true
                registerPasswordConfig.text = ""
            }
        }
        
        //        change the check images from red to green or do someother animation.
        if registerPassword.text == registerPasswordConfig.text {
            passwordCheckImg.image = UIImage.init(named: AppImages.GreenCheck)
            confirmPasswordCheckImg.image = UIImage.init(named: AppImages.GreenCheck)
        } else {
            passwordCheckImg.image = UIImage.init(named: AppImages.RedCheck)
            confirmPasswordCheckImg.image = UIImage.init(named: AppImages.RedCheck)
        }
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        
        guard let email = registerEmail.text , email.isNotEmpty,
              let username = registerUserName.text, username.isNotEmpty,
              let password = registerPassword.text, password.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please fill out all fields.")
            return
        }
        
        guard let confirmPass = registerPasswordConfig.text , confirmPass == password else {
            simpleAlert(title: "Error", msg: "Passwords do not match.")
            return
        }
        progressBar.startAnimating()
        
        //How To register with email and password
        //        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
        //            if let error = error {
        //                debugPrint(error)
        //                Auth.auth().handleFireAuthError(error: error, vc: self)
        //                return
        //            }
        //
        //            guard let firUser = result?.user else { return }
        //            let artUser = User.init(id: firUser.uid, email: email, username: username, stripeId: "")
        //            // Upload to Firestore
        //            self.createFirestoreUser(user: artUser)
        //        }
        
        
        //How To register with existing Provider
        guard let authUser = Auth.auth().currentUser else {
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        authUser.link(with: credential) { (result, error) in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            
            guard let firUser = result?.user else { return }
            let artUser = User.init(id: firUser.uid, email: email, username: username, stripeId: "")
            // Upload to Firestore
            self.createFirestoreUser(user: artUser)
        }
    }
    
    func createFirestoreUser(user: User) {
        // Step 1: Create document reference
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        
        // Step 2: Create model data
        let data = User.modelToData(user: user)
        
        // Step 3: Upload to Firestore.
        newUserRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("Error signing in: \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            self.progressBar.stopAnimating()
        }
    }
}
