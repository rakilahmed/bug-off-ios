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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDueDate = dateFormatter.date(from:  ticket.dueDate)!
        let formattedCreatedAt = dateFormatter.date(from:  ticket.createdAt)!
        let formattedUpdatedAt = dateFormatter.date(from:  ticket.updatedAt)!
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        dueDateLabel.text = dateFormatter.string(from: formattedDueDate)
        createdAtLabel.text = dateFormatter.string(from: formattedCreatedAt)
        updatedAtLabel.text = dateFormatter.string(from: formattedUpdatedAt)
        
        if segmentIdx == 1 {
            ticketStatusButton.setTitle("RESTORE", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func deleteTapped(_ sender: UIButton) {
        deleteTicket(ticketID: ticket!.id)
        if segmentIdx == 0 {
            openTickets.remove(at: ticketRowIdx!)
        } else {
            closedTickets.remove(at: ticketRowIdx!)
        }
        
        delegate?.viewTicketVC(self)
    }
    
    @IBAction func ticketStatusTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let updatedAtDate = dateFormatter.string(from: Date())
        
        let ticketStatus = segmentIdx == 0 ? "closed" : "open"
        
        let ticket = Ticket(id: ticket!.id, status: ticketStatus, submittedBy: ticket!.submittedBy, assignedTo: ticket!.assignedTo, title: ticket!.title, summary: ticket!.summary, priority: ticket!.priority, dueDate: ticket!.dueDate, createdAt: ticket!.createdAt, updatedAt: updatedAtDate)
        
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
