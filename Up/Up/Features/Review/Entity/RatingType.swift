//
//  RatingType.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

enum RatingType: Int, CaseIterable, Equatable, Identifiable {
    case workLifeBalance
    case welfare
    case salary
    case companyCulture
    case management
    
    var id: Int {
        rawValue
    }
    
    var text: String {
        switch self {
        case .workLifeBalance:
            "워라밸"
        case .welfare:
            "급여"
        case .salary:
            "복지"
        case .companyCulture:
            "사내문화"
        case .management:
            "경영진"
        }
    }
}
