//
//  UpdateProfileVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import Firebase
import FirebaseAuth

class UpdateProfileVC: UIViewController {
    
    @IBOutlet weak var currentNameLabel: UILabel!
    @IBOutlet weak var currentEmailLabel: UILabel!
    @IBOutlet weak var newNameField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Update Profile"
        currentNameLabel.text = Auth.auth().currentUser?.displayName
        currentEmailLabel.text = Auth.auth().currentUser?.email
        setupElements()
    }
    
    func setupElements() {
        Utilities.styleTextLabel(currentNameLabel)
        Utilities.styleTextLabel(currentEmailLabel)
        Utilities.styleTextField(newNameField)
        Utilities.styleTextField(newEmailField)
        Utilities.styleFilledButton(updateButton)
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        let newName = newNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let newEmail = newEmailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newName.isEmpty && newName != currentNameLabel.text {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = newName
            changeRequest?.commitChanges()
        } else if !newEmail.isEmpty && newEmail != currentEmailLabel.text {
            Auth.auth().currentUser?.updateEmail(to: newEmail)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
