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
    
    init() {
        self.id = 0
        self.name = ""
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

struct LegalDistrictsData: Equatable {
    let hasNext: Bool
    let currentPage: Int
    let legalDistricts: [District]
}
