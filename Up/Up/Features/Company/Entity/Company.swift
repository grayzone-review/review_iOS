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
        lotNumberAddress.isEmpty ? roadNameAddress : lotNumberAddress
    }
}

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double
}

struct CompanyDTO: Codable {
    let id: Int?
    let name: String?
    let permittedAt: String?
    let lotNumberAddress: String?
    let roadNameAddress: String?
    let totalRating: Double?
    let isFollowed: Bool?
    let longitude: Double?
    let latitude: Double?
    
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
        let permissionDate = DateFormatter.serverFormat.date(from: permittedAt ?? "")
        
        return Company(
            id: id ?? -1,
            name: name ?? "",
            permissionDate: permissionDate,
            address: Address(
                lotNumberAddress: lotNumberAddress ?? "",
                roadNameAddress: roadNameAddress ?? ""
            ),
            totalRating: totalRating ?? 0,
            isFollowed: isFollowed ?? false,
            coordinate: Coordinate(
                latitude: latitude ?? 37.5665,
                longitude: longitude ?? 126.9780
            )
        )
    }
}
