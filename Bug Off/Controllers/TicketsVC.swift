//
//  TicketsVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import FirebaseAuth

class TicketsVC: UITableViewController {
    var openTickets = [TicketElement]()
    var closedTickets = [TicketElement]()
    lazy var ticketsToDisplay = openTickets
    
    @IBOutlet weak var openClosedControl: UISegmentedControl!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
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
        return ticketsToDisplay.count == 0 ? 1 : ticketsToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentOption = openClosedControl.selectedSegmentIndex == 0 ? "open" : "closed"
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketCell.identifier, for: indexPath) as! TicketCell
        if ticketsToDisplay.count > 0 {
            if segmentOption == "open" {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].dueDate, priority: ticketsToDisplay[indexPath.row].priority)
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].updatedAt, priority: ticketsToDisplay[indexPath.row].priority)
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.configure(with: "No \(segmentOption) tickets to show...", status: "", date: "", priority: "")
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(ticketsToDisplay[indexPath.row].title)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func fetchTickets() {
        openTickets.removeAll()
        closedTickets.removeAll()
        
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
                            self.openTickets = userObject[0].tickets.filter { ticket in
                                return ticket.status == "open"
                            }
                            
                            self.closedTickets = userObject[0].tickets.filter { ticket in
                                return ticket.status == "closed"
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.refreshControl?.endRefreshing()
                            
                            if self.openClosedControl.selectedSegmentIndex == 0 {
                                self.ticketsToDisplay = self.openTickets
                            } else {
                                self.ticketsToDisplay = self.closedTickets
                            }
                            
                            self.tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func openClosedTapped(_ sender: UISegmentedControl) {
        switch openClosedControl.selectedSegmentIndex {
        case 0:
            ticketsToDisplay = openTickets
        case 1:
            ticketsToDisplay = closedTickets
        default:
            ticketsToDisplay = openTickets
        }
        
        tableView.reloadData()
    }
}
