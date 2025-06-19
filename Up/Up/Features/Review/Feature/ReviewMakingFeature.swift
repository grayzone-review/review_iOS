//
//  ReviewMakingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/19/25.
//

import ComposableArchitecture

@Reducer
struct ReviewMakingFeature {
    @ObservableState
    struct State: Equatable {
        var review: Review.State?
        private var reviewStates: [Review.State] = []
        
        var currentPage: Int {
            reviewStates.count
        }
    }
    
    enum Action {
        case closeButtonTapped
        case review(Review.Action)
    }
    
    @Reducer
    enum Review {}
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }
                
            case .review:
                return .none
            }
        }
        .ifLet(\.review, action: \.review) {
            Review.body
        }
    }
}

extension ReviewMakingFeature.Review.State: Equatable {}
