//
//  UpdateProfileVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/13/22.
//

import UIKit
import FirebaseAuth

class UpdateProfileVC: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var currentName: UILabel!
    @IBOutlet weak var currentEmail: UILabel!
    @IBOutlet weak var newNameField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    func setupElements() {
        title = toggle ? "Update Profile" : "Change Password"
        saveButton.isEnabled = false
        currentName.text = Auth.auth().currentUser?.displayName
        currentEmail.text = Auth.auth().currentUser?.email
        
        newNameField.delegate = self
        newEmailField.delegate = self
        newPasswordField.delegate = self
        confirmPasswordField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let profileHiddenRows = [4, 5]
        let passwordHiddenRows = [0, 1, 2, 3]
        
        if toggle {
            if profileHiddenRows.contains(indexPath.row) {
                return 0
            }
        } else {
            if passwordHiddenRows.contains(indexPath.row) {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if toggle {
            textField.resignFirstResponder()
        } else {
            switch textField {
            case newPasswordField:
                confirmPasswordField.becomeFirstResponder()
            default:
                confirmPasswordField.resignFirstResponder()
            }
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        saveButton.isEnabled = !textField.text!.isEmpty ? true : false
        return true
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        if toggle {
            let newName = newNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEmail = newEmailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !newName.isEmpty && newName != currentName.text {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = newName
                changeRequest?.commitChanges()
            } else if !newEmail.isEmpty && newEmail != currentEmail.text {
                Auth.auth().currentUser?.updateEmail(to: newEmail)
            } else {
                showAlert(title: "Faild to Update Profile", message: "Something went wrong, try again!")
            }
        } else {
            let newPassword = newPasswordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let confirmPassword = confirmPasswordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword {
                if Utilities.isPasswordValid(newPassword) == false {
                    showAlert(title: "Failed to Change Password ", message: "Please make sure your password is at least 6 characters or more.")
                } else {
                    Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
                        if error != nil {
                            self.showAlert(title: "Failed to Change Password", message: "\(error!.localizedDescription)")
                        }
                    }
                }
            } else {
                showAlert(title: "Uh Oh!", message: "Something went wrong, try again!")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
