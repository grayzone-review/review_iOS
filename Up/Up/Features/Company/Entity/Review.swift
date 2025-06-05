//
//  Review.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct Review: Equatable, Identifiable {
    let id: Int
    var rating: Rating
    var reviewer: String
    var title: String
    var advantagePoint: String
    var disadvantagePoint: String
    var managementFeedback: String
    var job: String
    var employmentPeriod: String
    let creationDate: Date
    var likeCount: Int
    var commentCount: Int
    var isLiked: Bool
    var isExpanded: Bool = false
}

extension Review {
    enum Point {
        case advantage
        case disadvantage
        case managementFeedback
        
        var accentColor: AppColor {
            switch self {
            case .advantage:
                return .seBlue50
            case .disadvantage:
                return .seRed50
            case .managementFeedback:
                return .gray50
            }
        }
        
        var backgroundColor: AppColor {
            switch self {
            case .advantage:
                return .seBlue10
            case .disadvantage:
                return .seRed10
            case .managementFeedback:
                return .gray10
            }
        }
        
        var keyword: String {
            switch self {
            case .advantage:
                return "장점"
            case .disadvantage:
                return "단점"
            case .managementFeedback:
                return "바라는 점"
            }
        }
    }
}

struct ReviewDTO: Codable {
    let id: Int
    let rating: RatingDTO
    var reviewer: String
    let title: String
    let advantagePoint: String
    let disadvantagePoint: String
    let managementFeedback: String
    let job: String
    let employmentPeriod: String
    let createdAt: String
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case rating = "ratings"
        case reviewer = "author"
        case title
        case advantagePoint
        case disadvantagePoint
        case managementFeedback
        case job = "jobRole"
        case employmentPeriod
        case createdAt
        case likeCount
        case commentCount
        case isLiked
    }
}

extension ReviewDTO {
    func toDomain() -> Review {
        let creationDate = DateFormatter.shared.date(from: createdAt) ?? .now
        
        return Review(
            id: id,
            rating: rating.toDomain(),
            reviewer: reviewer,
            title: title,
            advantagePoint: advantagePoint,
            disadvantagePoint: disadvantagePoint,
            managementFeedback: managementFeedback,
            job: job,
            employmentPeriod: employmentPeriod,
            creationDate: creationDate,
            likeCount: likeCount,
            commentCount: commentCount,
            isLiked: isLiked
        )
    }
}
