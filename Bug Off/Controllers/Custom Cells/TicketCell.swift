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
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    public func configure(with title: String, dueDate: String, priority: String) {
//        let dueDateOriginal = DateFormatter()
//        dueDateOriginal.dateFormat = "yyyy-MM-ddTHH:mm:ssZ"
//        let dueDateFormat = DateFormatter()
//        dueDateFormat.dateFormat = "MMM dd,yyyy"
//        print(dueDateOriginal.date(from: dueDate))
//        let date: Date? = dueDateOriginal.string(from: dueDate)
//        print(dueDateOriginal.date(from: dueDate))
//        print(dueDateFormat.string(from: date!))
        
        titleLabel.text = title
        dueDateLabel.text = dueDate
        priorityLabel.text = priority
        
        Utilities.stylePriorityTextLabel(priorityLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
