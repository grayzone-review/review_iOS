//
//  LegalDistrictsData.swift
//  Up
//
//  Created by Wonbi on 7/14/25.
//

struct District: Equatable, Identifiable {
    let id: Int
    let name: String
    
    var buttonName: String {
        name.components(separatedBy: " ").last ?? name
    }
}

struct LegalDistrictsData: Equatable {
    let hasNext: Bool
    let currentPage: Int
    let legalDistricts: [District]
}
