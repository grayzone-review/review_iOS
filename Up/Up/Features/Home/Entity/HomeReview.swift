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
    let company: SearchedCompanyDTO?
    let review: ReviewDTO?
    
    enum CodingKeys: String, CodingKey {
        case company
        case review = "companyReview"
    }
}

extension HomeReviewDTO {
    func toDomain() -> HomeReview {
        HomeReview(
            company: company?.toDomain() ?? SearchedCompany(
                id: -1,
                name: "",
                address: "",
                totalRating: 0,
                isFollowed: false,
                distance: nil,
                reviewTitle: nil
            ),
            review: review?.toDomain() ?? Review(
                id: -1,
                rating: Rating(
                    workLifeBalance: 0,
                    welfare: 0,
                    salary: 0,
                    companyCulture: 0,
                    management: 0
                ),
                reviewer: "",
                title: "",
                advantagePoint: "",
                disadvantagePoint: "",
                managementFeedback: "",
                job: "",
                employmentPeriod: "",
                creationDate: .now,
                likeCount: 0,
                commentCount: 0,
                isLiked: false
            )
        )
    }
}
