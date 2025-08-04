//
//  SearchedCompaniesBody.swift
//  Up
//
//  Created by Jun Young Lee on 6/13/25.
//

import Foundation

struct SearchedCompaniesBody: Codable {
    let companies: [SearchedCompanyDTO]
    let hasNext: Bool
    let currentPage: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case companies
        case hasNext
        case currentPage
        case totalCount
    }
}
