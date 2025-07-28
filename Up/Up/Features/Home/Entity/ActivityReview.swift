//
//  ActivityReview.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation

struct ActivityReview: Equatable, Identifiable {
    let id: Int
    var totalRating: Double
    var title: String
    var companyID: Int
    var companyName: String
    var companyAddress: String
    var job: String
    let creationDate: Date
    var likeCount: Int
    var commentCount: Int
}

struct ActivityReviewDTO: Codable {
    let id: Int
    let totalRating: Double
    let title: String
    var companyID: Int
    var companyName: String
    var companyAddress: String
    let job: String
    let createdAt: String
    let likeCount: Int
    let commentCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case totalRating
        case title
        case companyID = "companyId"
        case companyName
        case companyAddress
        case job = "jobRole"
        case createdAt
        case likeCount
        case commentCount
    }
}

extension ActivityReviewDTO {
    func toDomain() -> ActivityReview {
        let creationDate = DateFormatter.serverFormat.date(from: createdAt) ?? .now
        
        return ActivityReview(
            id: id,
            totalRating: totalRating,
            title: title,
            companyID: companyID,
            companyName: companyName,
            companyAddress: companyAddress,
            job: job,
            creationDate: creationDate,
            likeCount: likeCount,
            commentCount: commentCount
        )
    }
}
