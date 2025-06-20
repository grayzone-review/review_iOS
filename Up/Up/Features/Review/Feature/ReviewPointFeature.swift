//
//  ReviewPointFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/21/25.
//

import ComposableArchitecture

@Reducer
struct ReviewPointFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var reviewPoints = [Review.Point: String]()
        
        var isDoneButtonEnabled: Bool {
            reviewPoints.count == Review.Point.allCases.count
        }
    }
    
    enum Action {
        case inputReviewPointFieldTapped(Review.Point)
        case previousButtonTapped
        case doneButtonTapped
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case previousButtonTapped
            case doneButtonTapped
        }
    }
    
    @Reducer
    enum Destination {
        case advantage(TextInputSheetFeature)
        case disadvantage(TextInputSheetFeature)
        case managedmentFeedback(TextInputSheetFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .inputReviewPointFieldTapped(reviewPoint):
                let textInputState = TextInputSheetFeature.State(
                    title: reviewPoint.title,
                    placeholder: reviewPoint.placeholder,
                    minimum: 30,
                    maximum: 1000,
                    text: state.reviewPoints[reviewPoint] ?? ""
                )
                
                state.destination = switch reviewPoint {
                case .advantage:
                        .advantage(textInputState)
                case .disadvantage:
                        .disadvantage(textInputState)
                case .managementFeedback:
                        .managedmentFeedback(textInputState)
                }
                return .none
                
            case .previousButtonTapped:
                return .send(.delegate(.previousButtonTapped))
                
            case .doneButtonTapped:
                guard state.isDoneButtonEnabled else {
                    return .none
                }
                
                return .send(.delegate(.doneButtonTapped))
                
            case let .destination(.presented(.advantage(.delegate(.save(text))))):
                state.reviewPoints[.advantage] = text
                return .none
                
            case let .destination(.presented(.disadvantage(.delegate(.save(text))))):
                state.reviewPoints[.disadvantage] = text
                return .none
                
            case let .destination(.presented(.managedmentFeedback(.delegate(.save(text))))):
                state.reviewPoints[.managementFeedback] = text
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

extension ReviewPointFeature.Destination.State: Equatable {}
