//
//  RecentSearchTerm.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import Foundation
import SwiftData

@Model
final class RecentSearchTerm {
    @Attribute(.unique) var searchTerm: String
    var creationDate: Date
    
    init(
        searchTerm: String,
        creationDate: Date = .now
    ) {
        self.searchTerm = searchTerm
        self.creationDate = creationDate
    }
}
