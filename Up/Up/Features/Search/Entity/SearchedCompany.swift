//
//  SearchedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/7/25.
//

import Foundation

struct SearchedCompany: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let totalRating: Double
    var searchedDate: Date = .now
}
