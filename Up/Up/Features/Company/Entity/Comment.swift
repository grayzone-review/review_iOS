//
//  Comment.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct Comment: Equatable, Identifiable {
    let id: Int
    var content: String
    let commenter: String
    let creationDate: Date?
    var replyCount: Int
    var isSecret: Bool
    var isVisible: Bool
}

struct CommentDTO: Codable {
    let id: Int?
    let content: String?
    let commenter: String?
    let createdAt: String?
    let replyCount: Int?
    let isSecret: Bool?
    let isVisible: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content = "comment"
        case commenter = "authorName"
        case createdAt
        case replyCount
        case isSecret = "secret"
        case isVisible = "visible"
    }
}

extension CommentDTO {
    func toDomain() -> Comment {
        let creationDate = DateFormatter.serverFormat.date(from: createdAt ?? "")
        
        return Comment(
            id: id ?? -1,
            content: content ?? "",
            commenter: commenter ?? "",
            creationDate: creationDate,
            replyCount: replyCount ?? 0,
            isSecret: isSecret ?? true,
            isVisible: isVisible ?? false
        )
    }
}
