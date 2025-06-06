//
//  SearchTheme.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

enum SearchTheme {
    case keyword
    case near
    case neighborhood
    case interest
    
    var text: String {
        switch self {
        case .keyword:
            ""
        case .near:
            "내 근처 업체"
        case .neighborhood:
            "우리동네 업체"
        case .interest:
            "관심동네 업체"
        }
    }
}
