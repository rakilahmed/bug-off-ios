//
//  ProfileVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import Firebase
import FirebaseAuth

var toggle = true

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    let items = ["Chnage Name or Email", "Change Password"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    // MARK: - Helper Functions
    func setupElements() {
        title = "Profile"
        Utilities.styleHollowButton(logoutButton)
    }
    
    // MARK: - Actions
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "authStatus")
            UserDefaults.standard.set(0, forKey: "selectedTab")
            Utilities.updateRootVC()
            print("-> Logged out successfully <-")
        } catch {
            print("-> Failed to logout <-")
        }
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // MARK: - Table View Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if items[indexPath.row] == "Chnage Name or Email" {
            toggle = true
        } else if items[indexPath.row] == "Change Password" {
            toggle = false
        }
    }
}
