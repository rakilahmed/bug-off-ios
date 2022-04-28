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
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    func setupElements() {
        title = toggle ? "Chnage Name or Email" : "Change Password"
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
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(
            in: stringRange,
            with: string)
        if newText.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneButton.isEnabled = false
        return true
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        resetFields()
    }
    
    func resetFields() {
        newNameField.text = ""
        newEmailField.text = ""
        newPasswordField.text = ""
        confirmPasswordField.text = ""
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if toggle {
            let newName = newNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let newEmail = newEmailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !newName.isEmpty && newName != currentName.text {
                if newName.count < 3 {
                    showAlert(title: "Failed to Change Name", message: "Please make sure your name is at least 3 characters or more.")
                }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = newName
                changeRequest?.commitChanges()
            }
            
            if !newEmail.isEmpty && newEmail != currentEmail.text {
                Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
                    if error != nil {
                        self.showAlert(title: "Failed to Change Email", message: "\(error!.localizedDescription)")
                    }
                }
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
                showAlert(title: "Failed to Change Password ", message: "Passwords must match.")
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
