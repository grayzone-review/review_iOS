//
//  HomeReview.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

struct HomeReview: Equatable, Identifiable {
    let company: SearchedCompany
    let review: Review
    var id: Int {
        review.id
    }
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
