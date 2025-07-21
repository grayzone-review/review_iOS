//
//  Region.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

struct Region: Equatable, Codable {
    let id: Int
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
    }
}

struct RegionDTO: Codable {
    let id: Int
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case address
    }
}

extension RegionDTO {
    func toDomain() -> Region {
        Region(
            id: id,
            address: address
        )
    }
}
