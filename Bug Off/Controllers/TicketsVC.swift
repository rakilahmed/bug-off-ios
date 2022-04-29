//
//  TicketsVC.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/6/22.
//

import UIKit
import FirebaseAuth

var openTickets = [TicketElement]()
var closedTickets = [TicketElement]()

class TicketsVC: UITableViewController, AddEditTicketVCDelegate, ViewTicketVCDelegate {
    @IBOutlet weak var openClosedControl: UISegmentedControl!
    
    lazy var ticketsToDisplay = openTickets
    
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
            if segmentOption == "open" {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].dueDate, priority: ticketsToDisplay[indexPath.row].priority)
            } else {
                cell.configure(with: ticketsToDisplay[indexPath.row].title, status: segmentOption, date: ticketsToDisplay[indexPath.row].updatedAt, priority: ticketsToDisplay[indexPath.row].priority)
            }
        } else {
            cell.configure(with: "No \(segmentOption) tickets to show...", status: "", date: "", priority: "")
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ticketsToDisplay.count > 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "viewTicketVC") as! ViewTicketVC
            vc.delegate = self
            vc.ticket = ticketsToDisplay[indexPath.row]
            vc.ticketRowIdx = indexPath.row
            vc.segmentIdx = openClosedControl.selectedSegmentIndex
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    // MARK: - AddEditTicketVC Delegate
    func addEditTicketVC(_ controller: AddEditTicketVC, didFinishAdding ticket: TicketElement) {
        updateTickets()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - ViewTicketVC Delegate
    func viewTicketVC(_ controller: ViewTicketVC) {
        updateTickets()
        navigationController?.popViewController(animated: true)
    }
}
