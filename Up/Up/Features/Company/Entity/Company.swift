//
//  Company.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct Company: Equatable, Identifiable {
    let id: Int
    let name: String
    let permissionDate: Date?
    let address: Address
    let totalRating: Double
    var isFollowed: Bool
    let coordinate: Coordinate
}

struct Address: Equatable {
    let lotNumberAddress: String
    let roadNameAddress: String
}

extension Address {
    var displayText: String {
        roadNameAddress.isEmpty ? lotNumberAddress : roadNameAddress
    }
}

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

struct CompanyDTO: Codable {
    let id: Int
    let name: String
    let permittedAt: String
    let lotNumberAddress: String
    let roadNameAddress: String
    let totalRating: Double
    let isFollowed: Bool
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "companyName"
        case permittedAt = "permissionDate"
        case lotNumberAddress = "siteFullAddress"
        case roadNameAddress
        case totalRating
        case isFollowed = "following"
        case latitude
        case longitude
    }
}

extension CompanyDTO {
    func toDomain() -> Company {
        let permissionDate = DateFormatter.shared.date(from: permittedAt)
        
        return Company(
            id: id,
            name: name,
            permissionDate: permissionDate,
            address: Address(
                lotNumberAddress: lotNumberAddress,
                roadNameAddress: roadNameAddress
            ),
            totalRating: totalRating,
            isFollowed: isFollowed,
            coordinate: Coordinate(
                latitude: latitude,
                longitude: longitude
            )
        )
    }
}
