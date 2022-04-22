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
    
    public func configure(with title: String, status: String, date: String, priority: String) {
        var finalDate = ""
        if date != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let formattedDate = dateFormatter.date(from: date)!
            dateFormatter.dateFormat = "MMM d, h:mm a"
            finalDate = dateFormatter.string(from: formattedDate)
        }
        
        titleLabel.text = title
        dateLabel.text = date != "" ? (status == "open" ? "Due: " + finalDate : "Last updated: " + finalDate) : ""
        priorityLabel.text = priority
        
        Utilities.stylePriorityTextLabel(priorityLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
