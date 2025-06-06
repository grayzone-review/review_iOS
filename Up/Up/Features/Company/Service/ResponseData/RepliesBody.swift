//
//  RepliesBody.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct RepliesBody: Codable {
    let replies: [ReplyDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case replies
        case hasNext
        case currentPage
    }
}
