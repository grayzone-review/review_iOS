//
//  ReviewInformationFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture

@Reducer
struct ReviewInformationFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var company: ProposedCompany?
        var jobRole: String = ""
        var employmentPeriod: EmploymentPeriod?
        
        init(company: ProposedCompany? = nil) {
            self.company = company
        }
    }
    
    enum Action {
        case inputCompanyFieldTapped
        case inputJobRoleFieldTapped
        case selectEmploymentPeriodFieldTapped
        case nextButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case nextButtonTapped
        }
    }
    
    @Reducer
    enum Destination {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .inputCompanyFieldTapped:
                return .none
                
            case .inputJobRoleFieldTapped:
                return .none
                
            case .selectEmploymentPeriodFieldTapped:
                return .none
                
            case .nextButtonTapped:
                return .send(.delegate(.nextButtonTapped))
                    
            case .destination:
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ReviewInformationFeature.Destination.State: Equatable {}
