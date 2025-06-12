//
//  SearchedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/7/25.
//

import Foundation

struct SearchedCompany: Equatable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
    var isFollowed: Bool
    let distance: Double
    let reviewTitle: String?
}

struct SearchedCompanyDTO: Codable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
    let isFollowed: Bool
    let distance: Double
    let reviewTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "companyName"
        case address = "companyAddress"
        case totalRating
        case isFollowed = "following"
        case distance
        case reviewTitle
    }
}

extension SearchedCompanyDTO {
    func toDomain() -> SearchedCompany {
        SearchedCompany(
            id: id,
            name: name,
            address: address,
            totalRating: totalRating,
            isFollowed: isFollowed,
            distance: distance,
            reviewTitle: reviewTitle
        )
    }
}
