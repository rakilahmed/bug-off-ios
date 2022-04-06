//
//  ViewController.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    func setupButtons() {
        Utilities.styleFilledButton(registerButton)
        Utilities.styleHollowButton(loginButton)
    }


}

