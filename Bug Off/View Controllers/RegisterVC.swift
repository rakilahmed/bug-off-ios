//
//  RegisterViewController.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterVC: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    func setupElements() {
        errorLabel.alpha = 0
        Utilities.styleTextField(fullNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(registerButton)
    }
    
    func validateFields() -> String? {
        if fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        
        let checkPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(checkPassword) == false {
            return "Please make sure your password is at least 6 characters or more"
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        let error = validateFields()
        if error != nil {
            showError(error!)
        } else {
            let fullName = fullNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.showError("Error creating user")
                } else {
                    UserDefaults.standard.set(true, forKey: "authStatus")
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = fullName
                    changeRequest?.commitChanges { error in
                        print("-> Error changing displayName <-")
                    }
                    
                    Utilities.updateRootVC()
                }
            }
        }
    }
}
