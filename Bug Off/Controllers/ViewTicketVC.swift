//
//  ViewTicketVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/27/22.
//

import UIKit
import FirebaseAuth

protocol ViewTicketVCDelegate: AnyObject {
    func viewTicketVC(_ controller: ViewTicketVC)
}

class ViewTicketVC: UITableViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var priorityLable: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var remindMeLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var ticketStatusButton: UIButton!
    
    let URI = "https://bugoff.rakilahmed.com/api/tickets"
    
    weak var delegate: ViewTicketVCDelegate?
    var ticket: Ticket?
    var ticketRowIdx: Int?
    var segmentIdx: Int?
    var update: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTicket" {
            let controller = segue.destination as! AddEditTicketVC
            controller.title = "Edit Ticket"
            controller.update = {
                self.update!()
            }
            controller.ticketRowIdx = ticketRowIdx
            controller.doneButton.isEnabled = true
            controller.ticket = ticket
        }
    }
    
    // MARK: - Delete Ticket (API)
    func deleteTicket(ticketID: Int) {
        var request = URLRequest(url: URL(string: URI + "/\(ticketID)")!)
        request.httpMethod = "DELETE"
        let sessionConfiguration = URLSessionConfiguration.default
        
        Auth.auth().currentUser?.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken!)"
            ]
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if data == nil {
                    print("Error Deleting Ticket with ID \(ticketID)")
                }
            }.resume()
        }
    }
    
    // MARK: - Close Ticket (API)
    func updateTicketStatus(ticket: Ticket) {
        var request = URLRequest(url: URL(string: URI + "/\(ticket.id)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let sessionConfiguration = URLSessionConfiguration.default
        
        Auth.auth().currentUser?.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken!)"
            ]
            
            let userObject = User(id: Auth.auth().currentUser!.uid, email: Auth.auth().currentUser!.email!, tickets: [ticket], createdAt: ticket.createdAt, updatedAt: ticket.updatedAt)
            
            request.httpBody = try? JSONEncoder().encode(userObject)
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if data == nil {
                    print("Error Updating Ticket with ID \(ticket.id)")
                }
            }.resume()
        }
    }
    
    // MARK: - Helper Functions
    func setupElements() {
        title = "View Ticket"
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        guard let ticket = ticket else { return }
        
        titleLabel.text = ticket.title
        summaryLabel.text = ticket.summary
        priorityLable.text = ticket.priority
        
        Utilities.stylePriorityTextLabel(priorityLable)
        
        let formattedDueDate = Utilities.convertStringToDate(date: ticket.dueDate)
        let formattedCreatedAt = Utilities.convertStringToDate(date: ticket.createdAt)
        let formattedUpdatedAt = Utilities.convertStringToDate(date: ticket.updatedAt)
        
        dueDateLabel.text = Utilities.modifyDateLook(date: formattedDueDate)
        remindMeLabel.text = UserDefaults.standard.bool(forKey: "\(ticket.id)") ? "Yes" : "No"
        
        createdAtLabel.text = Utilities.modifyDateLook(date: formattedCreatedAt)
        updatedAtLabel.text = Utilities.modifyDateLook(date: formattedUpdatedAt)
        
        if segmentIdx == 1 {
            ticketStatusButton.setTitle("RESTORE", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteTicket(ticketID: ticket!.id)
        Utilities.removeNotification(ticketID: ticket!.id)
        
        if segmentIdx == 0 {
            openTickets.remove(at: ticketRowIdx!)
        } else {
            closedTickets.remove(at: ticketRowIdx!)
        }
    
        delegate?.viewTicketVC(self)
    }
    
    @IBAction func ticketStatusTapped(_ sender: UIButton) {
        let updatedAtDate = Utilities.convertDateToString(date: Date())
        let ticketStatus = segmentIdx == 0 ? "closed" : "open"
        
        let ticket = Ticket(id: ticket!.id, status: ticketStatus, submittedBy: ticket!.submittedBy, assignedTo: ticket!.assignedTo, assigneeEmail: ticket!.assigneeEmail, title: ticket!.title, summary: ticket!.summary, priority: ticket!.priority, dueDate: ticket!.dueDate, createdAt: ticket!.createdAt, updatedAt: updatedAtDate)
    
        UserDefaults.standard.removeObject(forKey: "\(ticket.id)")
        updateTicketStatus(ticket: ticket)
        
        if segmentIdx == 1 {
            openTickets.append(ticket)
            closedTickets.remove(at: ticketRowIdx!)
        } else {
            closedTickets.append(ticket)
            openTickets.remove(at: ticketRowIdx!)
        }
        
        delegate?.viewTicketVC(self)
    }
    
    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1 {
            return 2
        }
        
        return 1
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
