//
//  TicketsData.swift
//  Bug Off
//
//  Created by Rakil Ahmed on 4/13/22.
//

import Foundation

// MARK: - User
struct User: Codable {
    let id, email: String
    let tickets: [Ticket]
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, tickets
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Ticket
struct Ticket: Codable {
    let id: Int
    let status, submittedBy, assignedTo, assigneeEmail: String
    let title, summary, priority: String
    let dueDate, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status
        case submittedBy = "submitted_by"
        case assignedTo = "assigned_to"
        case assigneeEmail = "assignee_email"
        case title, summary, priority
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
