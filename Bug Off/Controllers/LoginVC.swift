//
//  LoginRegisterVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/11/22.
//

import UIKit

class LoginRegisterVC: UITableViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var loginState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func tuggleState(_ sender: UIButton!) {
        loginState = !loginState
        
        if loginState {
            print("Login State")
        } else {
            print("Register State")
        }
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton!) {
        print("Login Clicked")
    }
    
    @IBAction func registerTapped(_ sender: UIButton!) {
        print("Register Clicked")
    }
}
