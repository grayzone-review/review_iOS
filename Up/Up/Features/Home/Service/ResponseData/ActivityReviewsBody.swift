//
//  ActivityReviewsBody.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation

struct ActivityReviewsBody: Codable {
    let reviews: [ActivityReviewDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case reviews
        case hasNext
        case currentPage
    }
}
