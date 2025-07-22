//
//  FollowedCompaniesBody.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import Foundation

struct FollowedCompaniesBody: Codable {
    let companies: [FollowedCompanyDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case companies
        case hasNext
        case currentPage
    }
}
