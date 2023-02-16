//
//  RegisterVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 13.02.2023.
//

import UIKit
import FirebaseAuth

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
              let password = registerPassword.text, password.isNotEmpty,
              let confPassword = registerPasswordConfig.text , confPassword.isNotEmpty else { return }
        
        progressBar.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult , error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            self.progressBar.stopAnimating()
            
            print("successfully register new user")
        }
        
    }

}
