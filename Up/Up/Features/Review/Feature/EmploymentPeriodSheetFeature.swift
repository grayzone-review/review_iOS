//
//  EmploymentPeriodSheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture

@Reducer
struct EmploymentPeriodSheetFeature {
    @ObservableState
    struct State: Equatable {
        var selected: EmploymentPeriod?
    }
    
    enum Action {
        case select(EmploymentPeriod)
        case closeButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case select(EmploymentPeriod?)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .select(period):
                state.selected = period
                return .none
                
            case .closeButtonTapped:
                return .run { [period = state.selected] send in
                    await send(.delegate(.select(period)))
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
