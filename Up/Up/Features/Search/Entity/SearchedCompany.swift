//
//  SearchedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/7/25.
//

import SwiftData

@Model
final class SearchedCompany {
    @Attribute(.unique) var id: Int
    var name: String
    var address: String
    var totalRating: Double
    
    init(
        id: Int,
        name: String,
        address: String,
        totalRating: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.totalRating = totalRating
    }
}
