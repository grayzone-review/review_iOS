//
//  Untitled.swift
//  Up
//
//  Created by Wonbi on 7/23/25.
//

struct RegionResponse: Codable {
    let meta: Meta
    let documents: [KakaoRegion]
    
    func toDomain() -> String {
        guard let region = documents.first(where: { $0.regionType == "B" }) ?? documents.first else { return "" }
        
        return region.addressName
    }
}

struct Meta: Codable {
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
}

struct KakaoRegion: Codable {
    let regionType: String
    let addressName: String
    let region1DepthName: String
    let region2DepthName: String
    let region3DepthName: String
    let region4DepthName: String
    let code: String
    let x: Double
    let y: Double

    enum CodingKeys: String, CodingKey {
        case regionType = "region_type"
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case region4DepthName = "region_4depth_name"
        case code, x, y
    }
}
