//
//  Reply.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct Reply: Equatable, Identifiable {
    let id: Int
    var content: String
    let replier: String
    let creationDate: Date?
    var isSecret: Bool
    var isVisible: Bool
}

struct ReplyDTO: Codable {
    let id: Int
    let content: String
    let replier: String
    let createdAt: String
    let isSecret: Bool
    let isVisible: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case content = "comment"
        case replier = "authorName"
        case createdAt
        case isSecret = "secret"
        case isVisible = "visible"
    }
}

extension ReplyDTO {
    func toDomain() -> Reply {
        let creationDate = DateFormatter.shared.date(from: createdAt)
        
        return Reply(
            id: id,
            content: content,
            replier: replier,
            creationDate: creationDate,
            isSecret: isSecret,
            isVisible: isVisible
        )
    }
}
