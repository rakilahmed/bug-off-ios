//
//  DashboardVC.swift
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
        tableView.register(TicketCell.nib(), forCellReuseIdentifier: TicketCell.identifier)
        setupElements()
    }
    
    func setupElements() {
        title = "Tickets"
        fetchTickets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.tableView.refreshControl?.endRefreshing()
        }
        self.fetchTickets()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketCell.identifier, for: indexPath) as! TicketCell
        cell.configure(with: tickets[indexPath.row].title, dueDate: tickets[indexPath.row].dueDate, priority: tickets[indexPath.row].priority)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(tickets[indexPath.row].title)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func fetchTickets() {
        let request = URLRequest(url: URL(string: "https://bugoff.rakilahmed.com/api/tickets")!)
        let sessionConfiguration = URLSessionConfiguration.default
        
        Auth.auth().currentUser?.getIDToken() {idToken, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            sessionConfiguration.httpAdditionalHeaders = [
                "Authorization": "Bearer \(idToken!)"
            ]
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let userObject = try decoder.decode([Ticket].self, from: data)

                        if userObject.count > 0 {
                            self.tickets = userObject[0].tickets
                        }
                        
                        DispatchQueue.main.async {
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
