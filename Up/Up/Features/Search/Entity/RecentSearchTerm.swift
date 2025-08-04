//
//  RecentSearchTerm.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import Foundation

struct RecentSearchTerm: Codable, Equatable, Identifiable {
    let searchTerm: String
    var searchedDate: Date = .now
    
    var id: String {
        searchTerm
    }
}
