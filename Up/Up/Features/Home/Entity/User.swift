//
//  User.swift
//  Up
//
//  Created by Jun Young Lee on 7/17/25.
//

struct User: Equatable, Codable {
    let nickname: String
    let mainRegion: Region
    let interestedRegions: [Region]
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case mainRegion
        case interestedRegions
    }
}

struct UserDTO: Codable {
    let nickname: String?
    let mainRegionId: Int?
    let mainRegionAddress: String?
    let interestedRegions: [RegionDTO]?
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case mainRegionId
        case mainRegionAddress
        case interestedRegions
    }
}

extension UserDTO {
    func toDomain() -> User {
        User(
            nickname: nickname ?? "",
            mainRegion: Region(
                id: mainRegionId ?? -1,
                address: mainRegionAddress ?? ""
            ),
            interestedRegions: interestedRegions?.map { $0.toDomain() } ?? []
        )
    }
}
