//
//  HomeReview.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

import Foundation

struct HomeReview: Equatable, Identifiable {
    let id = UUID() // 응답으로 같은 리뷰를 받더라도 문제없이 보여주기 위한 UUID
    let company: SearchedCompany
    let review: Review
}

struct HomeReviewDTO: Codable {
    let company: SearchedCompanyDTO
    let review: ReviewDTO
    
    enum CodingKeys: String, CodingKey {
        case company
        case review = "companyReview"
    }
}

extension HomeReviewDTO {
    func toDomain() -> HomeReview {
        HomeReview(
            company: company.toDomain(),
            review: review.toDomain()
        )
    }
}
