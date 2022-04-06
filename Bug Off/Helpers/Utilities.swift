//
//  Utilities.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        textfield.layer.borderWidth = 1.0
        textfield.layer.cornerRadius = 10.0
        textfield.layer.borderColor = UIColor.init(red: 85/255, green: 42/255, blue: 42/255, alpha: 1).cgColor
    }
    
    static func styleFilledButton(_ button:UIButton) {
        button.layer.cornerRadius = 10.0
        button.backgroundColor = UIColor.init(red: 85/255, green: 42/255, blue: 42/255, alpha: 1)
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.init(red: 85/255, green: 42/255, blue: 42/255, alpha: 1).cgColor
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        return password.count >= 6
    }
    
}

