//
//  ProfileVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!

    let items = ["Update Profile", "Change Password"]

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if items[indexPath.row] == "Update Profile" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let updateProfileVC = storyBoard.instantiateViewController(withIdentifier: "updateProfileVC")
            self.navigationController?.pushViewController(updateProfileVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        setupElements()
    }
    
    func setupElements() {
        Utilities.styleHollowButton(logoutButton)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            UserDefaults.standard.set(false, forKey: "authStatus")
            try Auth.auth().signOut()
            Utilities.updateRootVC()
            print("-> Logged out successfully <-")
        } catch {
            print("-> Failed to logout <-")
        }
    }
    
}
