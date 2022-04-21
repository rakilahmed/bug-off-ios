//
//  TicketsVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import FirebaseAuth

class TicketsVC: UITableViewController {
    var tickets = [TicketElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
    }
    
    func setupElements() {
        title = "Tickets"
        tableView.register(TicketCell.nib(), forCellReuseIdentifier: TicketCell.identifier)
        
        fetchTickets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func pullToRefresh() {
        fetchTickets()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count == 0 ? 1 : tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketCell.identifier, for: indexPath) as! TicketCell
        if tickets.count > 0 {
            cell.configure(with: tickets[indexPath.row].title, dueDate: tickets[indexPath.row].dueDate, priority: tickets[indexPath.row].priority)
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.titleLabel.text = "No tickets to show..."
            cell.dueDateLabel.text = ""
            cell.priorityLabel.text = ""
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tickets[indexPath.row].title)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func fetchTickets() {
        tickets.removeAll()
        
        let request = URLRequest(url: URL(string: "https://bugoff.rakilahmed.com/api/tickets")!)
        let sessionConfiguration = URLSessionConfiguration.default
        
        Auth.auth().currentUser?.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken!)"
            ]
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let userObject = try decoder.decode([Ticket].self, from: data)
                        
                        if userObject.count > 0 {
                            self.tickets = userObject[0].tickets.reversed()
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.refreshControl?.endRefreshing()
                            self.tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
