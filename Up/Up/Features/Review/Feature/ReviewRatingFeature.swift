//
//  ReviewRatingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture

@Reducer
struct ReviewRatingFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var company: ProposedCompany
        var ratings = [RatingType: Int]()
        
        var totalRating: Double {
            guard ratings.isEmpty == false else {
                return 0.0
            }
            
            let total = ratings.reduce(0, { $0 + $1.value })
            let average = Double(total) / Double(ratings.count)
            
            return average.rounded(to: 1)
        }
        
        var isNextButtonEnabled: Bool {
            ratings.count == RatingType.allCases.count
        }
    }
    
    enum Action {
        case companyButtonTapped
        case ratingButtonTapped(RatingType, Int)
        case previousButtonTapped
        case nextButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case previousButtonTapped(ProposedCompany)
            case nextButtonTapped
        }
    }
    
    @Reducer
    enum Destination {
        case company(SelectCompanySheetFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .companyButtonTapped:
                state.destination = .company(
                    SelectCompanySheetFeature.State(
                        selected: state.company
                    )
                )
                return .none
                
            case let .ratingButtonTapped(type, rating):
                state.ratings[type] = rating
                return .none
                
            case .previousButtonTapped:
                return .send(.delegate(.previousButtonTapped(state.company)))
                
            case .nextButtonTapped:
                guard state.isNextButtonEnabled else {
                    return .none
                }
                
                return .send(.delegate(.nextButtonTapped))
                
            case let .destination(.presented(.company(.delegate(.select(company))))):
                state.company = company
                return .none
                    
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ReviewRatingFeature.Destination.State: Equatable {}
