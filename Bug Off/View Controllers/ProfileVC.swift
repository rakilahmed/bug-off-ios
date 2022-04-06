//
//  ProfileVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileVC: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = Auth.auth().currentUser?.displayName
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            UserDefaults.standard.set(false, forKey: "authStatus")
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(identifier: "loginVC")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(loginVC)
            print("-> Logged out successfully <-")
        } catch {
            print("-> Failed to logout <-")
        }
    }
    
}
