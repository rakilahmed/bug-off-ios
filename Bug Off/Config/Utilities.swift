//
//  Utilities.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import Foundation
import UIKit

class Utilities {
    static func updateRootVC() {
        let authStatus = UserDefaults.standard.bool(forKey: "authStatus")
        var rootVC: UIViewController?
                
        if authStatus == true {
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarVC")
        } else {
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginRegisterVC")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
    }
    
    static func styleTextField(_ textfield:UITextField) {
        textfield.layer.borderWidth = 0.5
        textfield.layer.cornerRadius = 5
        textfield.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 0.5).cgColor
    }
    
    static func styleTextLabel(_ label: UILabel) {
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 5
        label.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 1).cgColor
    }
    
    static func styleFilledButton(_ button:UIButton) {
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 1)
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 1).cgColor
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        return password.count >= 6
    }
    
}
