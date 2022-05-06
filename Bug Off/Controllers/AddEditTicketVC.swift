//
//  AddEditTicketVCDelegate.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/27/22.
//

import UIKit
import FirebaseAuth

protocol AddEditTicketVCDelegate: AnyObject {
    func addEditTicketVC(_ controller: AddEditTicketVC, didFinishAdding ticket: Ticket)
}

class AddEditTicketVC: UITableViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var summaryField: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    let URI = "https://bugoff.rakilahmed.com/api/tickets"
    
    weak var delegate: AddEditTicketVCDelegate?
    var priority: String?
    var ticket: Ticket?
    var update: (() -> Void)?
    var ticketRowIdx: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    // MARK: - Add Ticket (API)
    func addTicket(ticket: Ticket) {
        var request = URLRequest(url: URL(string: URI)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let sessionConfiguration = URLSessionConfiguration.default
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            guard let idToken = idToken else { return }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken)"
            ]
            
            let userObject = User(id: currentUser.uid, email: currentUser.email!, tickets: [ticket], createdAt: ticket.createdAt, updatedAt: ticket.updatedAt)
            
            request.httpBody = try? JSONEncoder().encode(userObject)
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if let data = data {
                    do {
                        let _ = try JSONDecoder().decode(Ticket.self, from: data)
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Edit Ticket (API)
    func editTicket(ticket: Ticket) {
        var request = URLRequest(url: URL(string: URI + "/\(ticket.id)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let sessionConfiguration = URLSessionConfiguration.default
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        currentUser.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            guard let idToken = idToken else { return }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken)"
            ]
            
            let userObject = User(id: currentUser.uid, email: currentUser.email!, tickets: [ticket], createdAt: ticket.createdAt, updatedAt: ticket.updatedAt)
            
            request.httpBody = try? JSONEncoder().encode(userObject)
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if data == nil {
                    print("Error Editing Ticket with ID \(ticket.id)")
                }
            }.resume()
        }
    }
    
    // MARK: - Helper Functions
    func setupElements() {
        guard let ticket = ticket else {
            Utilities.styleTextView(summaryField)
            titleField.delegate = self
            summaryField.delegate = self
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
            
            return
        }

        
        titleField.text = ticket.title
        summaryField.text = ticket.summary
        
        if ticket.priority == "Low" {
            priorityControl.selectedSegmentIndex = 0
            priority = "Low"
        } else if ticket.priority == "Medium" {
            priorityControl.selectedSegmentIndex = 1
            priority = "Medium"
        } else {
            priorityControl.selectedSegmentIndex = 2
            priority = "High"
        }
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDate = dateFormatter.date(from: ticket.dueDate)!
        dueDatePicker.date = formattedDate
        
    }
    
    func validateFields() -> String? {
        if titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || summaryField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all the fields."
        }
        return nil
    }
    
    func resetFields() {
        titleField.text = ""
        summaryField.text = ""
        priorityControl.selectedSegmentIndex = 0
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func random(digits:Int) -> Int {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return Int(number)!
    }
    
    // MARK: - Actions
    @IBAction func priorityTapped(_ sender: UISegmentedControl) {
        switch priorityControl.selectedSegmentIndex {
        case 1:
            priority = "Medium"
        case 2:
            priority = "High"
        default:
            priority = "Low"
        }
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        let errorMessage = validateFields()
        
        if errorMessage != nil {
            showAlert(title: "Failed to \(title!)", message: errorMessage!)
        } else {
            var id = random(digits: 4)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            var createdAt = dateFormatter.string(from: Date())
            var updatedAt = createdAt
            let dueDate = dateFormatter.string(from: dueDatePicker.date)
            
            if ticket != nil {
                id = ticket!.id
                createdAt = ticket!.createdAt
                updatedAt = dateFormatter.string(from: Date())
            }
            
            let title = titleField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let summary = summaryField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let ticket = Ticket(id: id, status: "open", submittedBy: Auth.auth().currentUser?.displayName ?? "Self", assignedTo: "Self", title: title, summary: summary, priority: priority ?? "Low", dueDate: dueDate, createdAt: createdAt, updatedAt: updatedAt)
            
            if self.ticket != nil {
                openTickets.remove(at: ticketRowIdx!)
                editTicket(ticket: ticket)
                openTickets.insert(ticket, at: ticketRowIdx!)
                
                update!()
                navigationController?.popToRootViewController(animated: true)
            } else {
                addTicket(ticket: ticket)
                openTickets.append(ticket)
                
                delegate?.addEditTicketVC(self, didFinishAdding: ticket)
            }
        }
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
}

extension AddEditTicketVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleField:
            summaryField.becomeFirstResponder()
        default:
            summaryField.resignFirstResponder()
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
}
