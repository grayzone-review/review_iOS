//
//  ReviewsBody.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct ReviewsBody: Codable {
    let reviews: [ReviewDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case reviews
        case hasNext
        case currentPage
    }
}
