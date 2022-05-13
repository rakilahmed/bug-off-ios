//
//  TicketCell.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/13/22.
//

import UIKit

class TicketCell: UITableViewCell {
    static let identifier = "TicketCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "TicketCell", bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    public func configure(with title: String, status: String, date: String, priority: String, closedTicket: Bool, notify: Bool) {
        let formattedDate = Utilities.convertStringToDate(date: date)
        let formattedStrDate = Utilities.modifyDateLook(date: formattedDate)
        
        titleLabel.text = title
        dateLabel.text = date != "" ? (status == "open" ? (notify ? "Due: " + formattedStrDate + " ⋅ 🔔" : "Due: " + formattedStrDate) : "Closed At: " + formattedStrDate) : ""
        priorityLabel.text = priority != "" && !closedTicket && formattedDate < Date() ? "Overdue" : priority
        
        Utilities.stylePriorityTextLabel(priorityLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
