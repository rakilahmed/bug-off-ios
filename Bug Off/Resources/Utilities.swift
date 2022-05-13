//
//  Utilities.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 3/30/22.
//

import Foundation
import UIKit

class Utilities {
    // MARK: - Helper Functions
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
    
    static func scheduleNotification(shouldRemind: Bool, notifyTime: Date, ticketID: Int, title: String, subtitle: String) {
        Utilities.removeNotification(ticketID: ticketID)
        
        if shouldRemind && notifyTime > Date() {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = "Take action now, it's due in an hour!"
            content.sound = UNNotificationSound.default
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyTime)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(ticketID)", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
    
    static func removeNotification(ticketID: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(ticketID)"])
    }
    
    static func convertStringToDate(date: String) -> Date {
        if date == "" { return Date() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: date)!
    }
    
    static func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        return dateFormatter.string(from: date)
    }
    
    static func modifyDateLook(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        return password.count >= 6
    }
    
    // MARK: - UI Styling
    static func styleTextField(_ textfield:UITextField) {
        textfield.layer.borderWidth = 0.5
        textfield.layer.cornerRadius = 5
        textfield.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 0.5).cgColor
    }
    
    static func styleTextView(_ textview:UITextView) {
        textview.layer.borderWidth = 0.5
        textview.layer.cornerRadius = 5
        textview.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 0.5).cgColor
    }
    
    static func styleTextLabel(_ label: UILabel) {
        label.layer.borderWidth = 1.0
        label.layer.cornerRadius = 5
        label.layer.borderColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 1).cgColor
    }
    
    static func stylePriorityTextLabel(_ label: UILabel) {
        label.textColor = UIColor.white
        label.layer.cornerRadius = 12
        
        if label.text == "Low" {
            label.layer.backgroundColor = UIColor.init(red: 91/255, green: 194/255, blue: 143/255, alpha: 1).cgColor
        } else if label.text == "Medium" {
            label.layer.backgroundColor = UIColor.init(red: 243/255, green: 191/255, blue: 51/255, alpha: 1).cgColor
        } else if label.text == "High" {
            label.layer.backgroundColor = UIColor.init(red: 215/255, green: 59/255, blue: 48/255, alpha: 1).cgColor
        } else if label.text == "Overdue" {
            label.layer.backgroundColor = UIColor.init(red: 48/255, green: 48/255, blue: 56/255, alpha: 1).cgColor
        } else {
            label.layer.backgroundColor = .none
        }
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
}

