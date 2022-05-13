//
//  TicketsVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import FirebaseAuth

var openTickets = [Ticket]()
var closedTickets = [Ticket]()

class TicketsVC: UITableViewController, AddEditTicketVCDelegate, ViewTicketVCDelegate {
    @IBOutlet weak var openClosedControl: UISegmentedControl!
    
    lazy var ticketsToDisplay = openTickets
    var currentTicketIdx: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        fetchTickets()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTicket" {
            let controller = segue.destination as! AddEditTicketVC
            controller.title = "Add Ticket"
            controller.delegate = self
        }
    }
    
    // MARK: - Fetching Tickets (API)
    @objc func fetchTickets() {
        openTickets.removeAll()
        closedTickets.removeAll()
        
        let request = URLRequest(url: URL(string: "https://bugoff.rakilahmed.com/api/tickets")!)
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
            
            URLSession(configuration: sessionConfiguration).dataTask(with: request) { (data, _, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let userObject = try decoder.decode([User].self, from: data)
                        
                        if userObject.count > 0 {
                            openTickets = userObject[0].tickets.filter { ticket in
                                return ticket.status == "open"
                            }
                            
                            closedTickets = userObject[0].tickets.filter { ticket in
                                return ticket.status == "closed"
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.refreshControl?.endRefreshing()
                            self.updateTickets()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Helper Functions
    func setupElements() {
        title = "Tickets"
        tableView.register(TicketCell.nib(), forCellReuseIdentifier: TicketCell.identifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchTickets), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func updateTickets() {
        ticketsToDisplay.removeAll()
        
        if self.openClosedControl.selectedSegmentIndex == 0 {
            ticketsToDisplay = openTickets
        } else {
            ticketsToDisplay = closedTickets
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func openClosedTapped(_ sender: UISegmentedControl) {
        switch openClosedControl.selectedSegmentIndex {
        case 1:
            ticketsToDisplay = closedTickets
        default:
            ticketsToDisplay = openTickets
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketsToDisplay.count == 0 ? 1 : ticketsToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let segmentOption = openClosedControl.selectedSegmentIndex == 0 ? "open" : "closed"
        let cell = tableView.dequeueReusableCell(withIdentifier: TicketCell.identifier, for: indexPath) as! TicketCell
                        
        if ticketsToDisplay.count > 0 {
            let remindMe = UserDefaults.standard.bool(forKey: "\(ticketsToDisplay[indexPath.row].id)")
            
            if segmentOption == "open" {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].dueDate, priority: ticketsToDisplay[indexPath.row].priority, closedTicket: false, notify: remindMe)
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].updatedAt, priority: ticketsToDisplay[indexPath.row].priority, closedTicket: true, notify: false)
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.configure(with: "No \(segmentOption) tickets to show...", status: "", date: "", priority: "", closedTicket: false, notify: false)
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ticketsToDisplay.count > 0 {
            currentTicketIdx = indexPath.row
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewTicketVC") as! ViewTicketVC
            vc.delegate = self
            vc.ticket = ticketsToDisplay[currentTicketIdx!]
            vc.ticketRowIdx = currentTicketIdx
            vc.segmentIdx = openClosedControl.selectedSegmentIndex
            vc.update = {
                self.updateTickets()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    // MARK: - AddEditTicketVC Delegate
    func addEditTicketVC(_ controller: AddEditTicketVC, didFinishAdding ticket: Ticket) {
        updateTickets()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - ViewTicketVC Delegate
    func viewTicketVC(_ controller: ViewTicketVC) {
        updateTickets()
        navigationController?.popViewController(animated: true)
    }
}
