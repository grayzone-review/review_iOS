//
//  Rating.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

struct Rating: Equatable {
    var workLifeBalance: Double
    var welfare: Double
    var salary: Double
    var companyCulture: Double
    var management: Double
}

extension Rating {
    var totalRating: Double {
        let ratings = [
            workLifeBalance,
            welfare,
            salary,
            companyCulture,
            management,
        ]
        
        return ratings.reduce(0, +) / Double(ratings.count)
    }
    
    var displayText: String {
        String(totalRating.rounded(to: 1))
    }
}

struct RatingDTO: Codable {
    let workLifeBalance: Double
    let welfare: Double
    let salary: Double
    let companyCulture: Double
    let management: Double
    
    enum CodingKeys: String, CodingKey {
        case workLifeBalance
        case welfare
        case salary
        case companyCulture
        case management
    }
}

extension RatingDTO {
    func toDomain() -> Rating {
        return Rating(
            workLifeBalance: workLifeBalance,
            welfare: welfare,
            salary: salary,
            companyCulture: companyCulture,
            management: management
        )
    }
}
