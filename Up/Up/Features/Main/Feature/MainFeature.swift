//
//  MainFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/27/25.
//

import ComposableArchitecture

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case makeReviewButtonTapped
        case tabSelected(Tab)
        case home(HomeFeature.Action)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    enum Tab {
        case home
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                return .none
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .home:
                return .none
            }
        }
    }
}

extension MainFeature.Destination.State: Equatable {}
