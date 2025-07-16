//
//  LegalDistrictResponse.swift
//  Up
//
//  Created by Wonbi on 7/14/25.
//

public struct LegalDistrict: Codable {
    /// 법정동 주소 ID
    public let id: Int
    /// 법정동 주소 이름
    public let name: String
    
    func toDomain() -> District {
        return District(
            id: self.id,
            name: self.name
        )
    }
}

public struct LegalDistrictResponse: Codable {
    public let legalDistricts: [LegalDistrict]
    public let hasNext: Bool
    public let currentPage: Int
    
    func toDomain() -> LegalDistrictsData {
        return LegalDistrictsData(
            hasNext: self.hasNext,
            currentPage: self.currentPage,
            legalDistricts: self.legalDistricts.map { $0.toDomain() }
        )
    }
}
