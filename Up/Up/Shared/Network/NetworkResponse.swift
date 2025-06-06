//
//  NetworkResponse.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct NetworkResponse<T: Codable>: Codable {
    let data: T
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case message
    }
}
