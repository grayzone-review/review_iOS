//
//  FollowedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation

struct FollowedCompany: Equatable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
    let reviewTitle: String?
}

struct FollowedCompanyDTO: Codable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
    let reviewTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "companyName"
        case address = "companyAddress"
        case totalRating
        case reviewTitle
    }
}

extension FollowedCompanyDTO {
    func toDomain() -> FollowedCompany {
        FollowedCompany(
            id: id,
            name: name,
            address: address,
            totalRating: totalRating,
            reviewTitle: reviewTitle
        )
    }
}
