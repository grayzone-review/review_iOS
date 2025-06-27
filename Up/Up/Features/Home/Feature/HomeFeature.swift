//
//  HomeFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/27/25.
//

import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case makeReviewButtonTapped
        case selectInterestButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case .selectInterestButtonTapped:
                return .none // 이후 명확한 동작이 정리되면 destination 관련 작업 진행
                
            case .destination:
                return .none
            }
        }
    }
}

extension HomeFeature.Destination.State: Equatable {}
