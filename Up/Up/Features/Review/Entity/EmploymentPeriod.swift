//
//  EmploymentPeriod.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

enum EmploymentPeriod: Int, Identifiable, CaseIterable {
    case lessThanOneYear
    case oneYearOrMore
    case twoYearsOrMore
    case threeYearsOrMore
    case fourYearsOrMore
    case fiveYearsOrMore
    
    var id: Int {
        rawValue
    }
    
    var text: String {
        switch self {
        case .lessThanOneYear:
            "1년 미만"
        case .oneYearOrMore:
            "1년 이상"
        case .twoYearsOrMore:
            "2년 이상"
        case .threeYearsOrMore:
            "3년 이상"
        case .fourYearsOrMore:
            "4년 이상"
        case .fiveYearsOrMore:
            "5년 이상"
        }
    }
}
