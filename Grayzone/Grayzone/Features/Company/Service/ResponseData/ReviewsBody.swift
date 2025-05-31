//
//  ReviewsBody.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct ReviewsBody: Codable {
    let reivews: [ReviewDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case reivews
        case hasNext
        case currentPage
    }
}
