//
//  HomeReviewsBody.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

import Foundation

struct HomeReviewsBody: Codable {
    let reviews: [HomeReviewDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case reviews
        case hasNext
        case currentPage
    }
}
