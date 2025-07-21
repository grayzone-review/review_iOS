//
//  InteractionCounts.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation

struct InteractionCounts: Equatable {
    let myReviewCount: Int
    let interactedReviewCount: Int
    let followedCompanyCount: Int
}

struct InteractionCountsDTO: Codable {
    let myReviewCount: Int
    let interactedReviewCount: Int
    let followedCompanyCount: Int
    
    enum CodingKeys: String, CodingKey {
        case myReviewCount
        case interactedReviewCount = "likeOrCommentReviewCount"
        case followedCompanyCount = "followCompanyCount"
    }
}

extension InteractionCountsDTO {
    func toDomain() -> InteractionCounts {
        InteractionCounts(
            myReviewCount: myReviewCount,
            interactedReviewCount: interactedReviewCount,
            followedCompanyCount: followedCompanyCount
        )
    }
}
