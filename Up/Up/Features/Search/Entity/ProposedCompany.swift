//
//  ProposedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/13/25.
//

import Foundation

struct ProposedCompany: Equatable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
}

struct ProposedCompanyDTO: Codable {
    let id: Int?
    let name: String?
    let address: String?
    let totalRating: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "companyName"
        case address = "companyAddress"
        case totalRating
    }
}

extension ProposedCompanyDTO {
    func toDomain() -> ProposedCompany {
        ProposedCompany(
            id: id ?? -1,
            name: name ?? "",
            address: address ?? "",
            totalRating: totalRating ?? 0
        )
    }
}
