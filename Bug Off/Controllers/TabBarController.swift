//
//  TabBarController.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/7/22.
//

import Foundation
import UIKit
import FirebaseAuth

class TabBarController: UITabBarController, UITabBarControllerDelegate {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if UserDefaults.standard.object(forKey: "selectedTab") != nil {
            self.selectedIndex = UserDefaults.standard.integer(forKey: "selectedTab")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UserDefaults.standard.set(self.selectedIndex, forKey: "selectedTab")
        UserDefaults.standard.synchronize()
    }
}
