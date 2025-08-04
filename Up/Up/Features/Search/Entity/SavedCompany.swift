//
//  SavedCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/13/25.
//

import Foundation

struct SavedCompany: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let address: String
    var savedDate: Date = .now
}
