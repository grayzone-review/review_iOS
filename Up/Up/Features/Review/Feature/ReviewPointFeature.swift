//
//  ReviewPointFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/21/25.
//

import ComposableArchitecture
import SwiftUI

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
            case doneButtonTapped(
                advantage: String,
                disAdavantage: String,
                managementFeedback: String
            )
        }
    }
    
    @Reducer
    enum Destination {
        case advantage(TextInputSheetFeature)
        case disadvantage(TextInputSheetFeature)
        case managementFeedback(TextInputSheetFeature)
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
                        .managementFeedback(textInputState)
                }
                return .none
                
            case .previousButtonTapped:
                return .send(.delegate(.previousButtonTapped))
                
            case .doneButtonTapped:
                guard state.isDoneButtonEnabled else {
                    return .none
                }
                
                return .send(.delegate(.doneButtonTapped(
                    advantage: state.reviewPoints[.advantage, default: ""],
                    disAdavantage: state.reviewPoints[.disadvantage, default: ""],
                    managementFeedback: state.reviewPoints[.managementFeedback, default: ""]
                )))
                
            case let .destination(.presented(.advantage(.delegate(.save(text))))):
                state.reviewPoints[.advantage] = text
                return .none
                
            case let .destination(.presented(.disadvantage(.delegate(.save(text))))):
                state.reviewPoints[.disadvantage] = text
                return .none
                
            case let .destination(.presented(.managementFeedback(.delegate(.save(text))))):
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

struct ReviewPointView: View {
    @Bindable var store: StoreOf<ReviewPointFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    advantageField
                    disadvantageField
                    managementFeedbackField
                }
                .padding(.horizontal, 20)
            }
            buttons
        }
    }
    
    private var advantageField: some View {
        reviewPointField(point: .advantage)
            .sheet(
                item: $store.scope(state: \.destination?.advantage, action: \.destination.advantage)
            ) { sheetStore in
                TextInputSheetView(store: sheetStore)
            }
    }
    
    private var disadvantageField: some View {
        reviewPointField(point: .disadvantage)
            .sheet(
                item: $store.scope(state: \.destination?.disadvantage, action: \.destination.disadvantage)
            ) { sheetStore in
                TextInputSheetView(store: sheetStore)
            }
    }
    
    private var managementFeedbackField: some View {
        reviewPointField(point: .managementFeedback)
            .sheet(
                item: $store.scope(state: \.destination?.managementFeedback, action: \.destination.managementFeedback)
            ) { sheetStore in
                TextInputSheetView(store: sheetStore)
            }
    }
    
    private func reviewPointField(point: Review.Point) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(point.title)
                .pretendard(.h3Bold, color: .gray90)
            
            Button {
                store.send(.inputReviewPointFieldTapped(point))
            } label: {
                HStack(spacing: 8) {
                    Text(store.reviewPoints[point] ?? point.placeholder)
                        .pretendard(.body1Regular, color: store.reviewPoints[point] == nil ? .gray50 : .gray90)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    Spacer()
                }
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(AppColor.gray20.color)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            previousButton
            doneButton
        }
        .padding(20)
    }
    
    private var previousButton: some View {
        AppButton(
            style: .stroke,
            size: .large, 
            text: "이전"
        ) {
            store.send(.previousButtonTapped)
        }
    }
    
    private var doneButton: some View {
        AppButton(
            style: .fill,
            size: .large,
            text: "작성완료",
            isEnabled: store.isDoneButtonEnabled
        ) {
            store.send(.doneButtonTapped)
        }
    }
}

#Preview {
    ReviewPointView(
        store: Store(
            initialState: ReviewPointFeature.State()
        ) {
            ReviewPointFeature()
        }
    )
}
