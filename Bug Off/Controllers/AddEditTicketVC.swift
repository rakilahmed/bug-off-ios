//
//  TicketDetailVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/27/22.
//

import UIKit
import FirebaseAuth

class AddEditTicketVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var summaryField: UITextView!
    @IBOutlet weak var priorityField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var updateTable: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    func setupElements() {
        Utilities.styleTextView(summaryField)
        
        titleField.delegate = self
        summaryField.delegate = self
        priorityField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleField:
            summaryField.becomeFirstResponder()
        default:
            priorityField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(
            in: stringRange,
            with: string)
        if newText.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneButton.isEnabled = false
        return true
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
        resetFields()
    }
    
    func resetFields() {
        titleField.text = ""
        summaryField.text = ""
        priorityField.text = ""
    }
    
    func random(digits:Int) -> Int {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return Int(number)!
    }
    
    func addTicket(ticket: TicketElement) {
        var request = URLRequest(url: URL(string: "https://bugoff.rakilahmed.com/api/tickets")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let sessionConfiguration = URLSessionConfiguration.default
        
        Auth.auth().currentUser?.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken!)"
            ]
            
            let userObj = Ticket(id: Auth.auth().currentUser!.uid, email: Auth.auth().currentUser!.email!, tickets: [ticket], createdAt: ticket.createdAt, updatedAt: ticket.updatedAt)
            
            request.httpBody = try? JSONEncoder().encode(userObj)
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if let data = data {
                    do {
                        let _ = try JSONDecoder().decode(TicketElement.self, from: data)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let createUpdateDate = dateFormatter.string(from: Date())
        let dueDate = dateFormatter.string(from: dueDatePicker.date)
        
        let ticket = TicketElement(id: random(digits: 4), status: "open", submittedBy: Auth.auth().currentUser?.displayName ?? "Self", assignedTo: "Self", title: titleField.text!, summary: summaryField.text!, priority: priorityField.text!, dueDate: dueDate, createdAt: createUpdateDate, updatedAt: createUpdateDate)
        
        addTicket(ticket: ticket)
        openTickets.append(ticket)
        
        updateTable?()
        navigationController?.popViewController(animated: true)
    }
}
