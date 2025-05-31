//
//  CommentsBody.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct CommentsBody: Codable {
    let comments: [CommentDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case comments
        case hasNext
        case currentPage
    }
}
