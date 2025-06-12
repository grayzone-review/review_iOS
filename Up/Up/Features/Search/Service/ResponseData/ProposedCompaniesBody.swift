//
//  ProposedCompaniesBody.swift
//  Up
//
//  Created by Jun Young Lee on 6/13/25.
//

import Foundation

struct ProposedCompaniesBody: Codable {
    let companies: [ProposedCompanyDTO]
    let hasNext: Bool
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case companies
        case hasNext
        case currentPage
    }
}
