//
//  SearchCompany.swift
//  Up
//
//  Created by Jun Young Lee on 6/5/25.
//

import ComposableArchitecture

@Reducer
struct SearchCompanyFeature {
    @ObservableState
    struct State: Equatable {
        var searchState: SearchState
        var searchTerm: String
    }
    
    enum Action {
        case backButtonTapped
        case textFieldFocused
        case clearButtonTapped
        case cancelButtonTapped
        case enterButtonTapped
        case termChanged
        case fetchRelatedCompanies
    }
    
    enum CancelID { case debounce }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .textFieldFocused:
                state.searchState = .focused
                return .none
                
            case .clearButtonTapped:
                state.searchTerm = ""
                return .run { send in
                    await send(.textFieldFocused)
                }
                
            case .cancelButtonTapped:
                state.searchTerm = ""
                state.searchState = .idle
                return .none
                
            case .enterButtonTapped:
                state.searchState = .submitted
                return .none
                
            case .termChanged:
                return .send(.fetchRelatedCompanies)
                    .debounce(
                        id: CancelID.debounce,
                        for: 0.5,
                        scheduler: mainQueue
                    )
                
            case .fetchRelatedCompanies:
                return .none // service 구현 이후 연관 검색어 API 호출로 변경 필요
            }
        }
    }
}
