//
//  TabBarController.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/7/22.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
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
