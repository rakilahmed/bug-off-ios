//
//  LoginRegisterVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/11/22.
//

import UIKit
import FirebaseAuth

class LoginRegisterVC: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var loginState = true
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                UserDefaults.standard.set(true, forKey: "authStatus")
            } else {
                UserDefaults.standard.set(false, forKey: "authStatus")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    func setupElements() {
        Utilities.styleTextField(nameField)
        Utilities.styleTextField(emailField)
        Utilities.styleTextField(passwordField)
        Utilities.styleFilledButton(loginButton)
        Utilities.styleFilledButton(registerButton)
        
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        resetFields()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let loginHiddenRows = [1, 5, 6]
        let registerHiddenRows = [4, 7]
        
        if indexPath.row == 0 {
            return tableView.bounds.height * 0.3
        }
        
        if loginState {
            if loginHiddenRows.contains(indexPath.row) {
                return 0
            }
        } else {
            if registerHiddenRows.contains(indexPath.row) {
                return 0
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            passwordField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardHeight.height / 4
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func validateFields(check: String) -> String? {
        if check == "login" {
            if  emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                    passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return "Please fill in all the fields."
            }
        } else {
            if nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                return "Please fill in all the fields."
            }
            
            if nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
                return "Please make sure your name is at least 3 characters or more."
            }
            
            let checkPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if Utilities.isPasswordValid(checkPassword) == false {
                return "Please make sure your password is at least 6 characters or more."
            }
        }
        
        return nil
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        resetFields()
    }
    
    func resetFields() {
        nameField.text = ""
        emailField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        var errorMessage = validateFields(check: "login")
        if errorMessage != nil {
            showAlert(title: "Failed to Login", message: errorMessage!)
        } else {
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    errorMessage = error!.localizedDescription
                    self.showAlert(title: "Failed to Login", message: errorMessage!)
                } else {
                    Utilities.updateRootVC()
                }
            }
        }
        resetFields()
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        var errorMessage = validateFields(check: "register")
        if errorMessage != nil {
            showAlert(title: "Failed to Register", message: errorMessage!)
        } else {
            let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    errorMessage = error!.localizedDescription
                    self.showAlert(title: "Failed to Register", message: errorMessage!)
                } else {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges()
                    Utilities.updateRootVC()
                }
            }
        }
    }
    
    @IBAction func toggleState(_ sender: UIButton) {
        loginState = !loginState
        tableView.reloadData()
    }
}
