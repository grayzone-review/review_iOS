//
//  SearchIdle.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import ComposableArchitecture

@Reducer
struct SearchIdleFeature {
    @ObservableState
    struct State: Equatable {
        let recentSearchTerms: [RecentSearchTerm]
    }
    
    enum Action {
        case delegate(Delegate)
        case recentSearchTermTapped(RecentSearchTerm)
        case deleteButtonTapped(RecentSearchTerm)
        case nearThemeButtonTapped
        case neighborhoodThemeButtonTapped
        case interestThemeButtonTapped
        
        enum Delegate: Equatable {
            case deleteSearchTerm(RecentSearchTerm)
            case search(String, SearchTheme)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .delegate:
                return .none
                
            case let .recentSearchTermTapped(recentSearchTerm):
                return .send(.delegate(.search(recentSearchTerm.searchTerm, .keyword)))
                
            case let .deleteButtonTapped(recentSearchTerm):
                return .send(.delegate(.deleteSearchTerm(recentSearchTerm)))
                
            case .nearThemeButtonTapped:
                return .send(.delegate(.search("#내 근처 업체", .near)))
                
            case .neighborhoodThemeButtonTapped:
                return .send(.delegate(.search("#우리 동네 업체", .neighborhood)))
                
            case .interestThemeButtonTapped:
                return .send(.delegate(.search("#관심 동네 업체", .interest)))
            }
        }
    }
}
