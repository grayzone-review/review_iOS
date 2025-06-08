//
//  SearchSubmitted.swift
//  Up
//
//  Created by Jun Young Lee on 6/8/25.
//

import ComposableArchitecture

@Reducer
struct SearchSubmittedFeature {
    @ObservableState
    struct State: Equatable {
        let searchTheme: SearchTheme
        var needLoad: Bool = true
        var searchedCompanies: [SearchedCompany] = []
    }
    
    enum Action {
        case viewInit
        case delegate(Delegate)
        case themeButtonTapped(SearchTheme)
        case followButtonTapped(SearchedCompany)
        case follow(id: Int, isFollowed: Bool)
        
        enum Delegate: Equatable {
            case search(String, SearchTheme)
        }
    }
    
    enum CancelID: Hashable {
        case follow(id: Int)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.companyService) var companyService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewInit:
                // service 정의 후 검색결과 로딩 API 호출 예정
                return .none
                
            case .delegate:
                return .none
                
            case let .themeButtonTapped(searchTheme):
                return .send(.delegate(.search("#\(searchTheme.text)", searchTheme)))
                
            case let .followButtonTapped(company):
                guard let index = state.searchedCompanies.firstIndex(where: { $0.id == company.id }) else {
                    return .none
                }
                
                state.searchedCompanies[index].isFollowed.toggle()
                return .send(.follow(id: company.id, isFollowed: state.searchedCompanies[index].isFollowed))
                    .debounce(
                        id: CancelID.follow(id: company.id),
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case let .follow(id, isFollowed):
                return .run { _ in
                    if isFollowed {
                        try await companyService.createCompanyFollowing(of: id)
                    } else {
                        try await companyService.deleteCompanyFollowing(of: id)
                    }
                }
            }
        }
    }
}
