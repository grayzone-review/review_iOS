//
//  HomeReviewCategory.swift
//  Up
//
//  Created by Jun Young Lee on 7/20/25.
//

enum HomeReviewCategory: Equatable {
    case popular
    case mainRegion(String?)
    case interestedRegion
    
    var title: String {
        switch self {
        case .popular:
            return "인기 있는 리뷰"
        case let .mainRegion(address):
            let region = address?.split(separator: " ").last
            return "\(region ?? "우리 동네") 최근 리뷰"
        case .interestedRegion:
            return "관심 동네 리뷰"
        }
    }
}
