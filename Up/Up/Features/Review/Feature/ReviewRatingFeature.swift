//
//  ReviewRatingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture
import SwiftUI

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

struct ReviewRatingView: View {
    @Bindable var store: StoreOf<ReviewRatingFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Divider()
                    information
                    Divider()
                    ratingButtons
                }
            }
            buttons
        }
    }
    
    private var information: some View {
        VStack(spacing: 12) {
            companyButton
            totalRating
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppColor.gray10.color)
    }
    
    private var companyButton: some View {
        Button {
            store.send(.companyButtonTapped)
        } label: {
            Text(store.company.name)
                .pretendard(.h3, color: .orange40)
        }
        .sheet(
            item: $store.scope(state: \.destination?.company, action: \.destination.company)
        ) { sheetStore in
            SelectCompanySheetView(store: sheetStore)
        }
    }
    
    private var totalRating: some View {
        HStack(spacing: 8) {
            StarRatingView(rating: store.totalRating, length: 36)
            Text(String(store.totalRating))
                .pretendard(.h1, color: store.isNextButtonEnabled ? .gray90 : .gray50)
        }
    }
    
    @ViewBuilder
    private var ratingButtons: some View {
        ScrollView {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(RatingType.allCases) { type in
                        Text(type.text)
                            .pretendard(.body1Regular, color: .gray90)
                            .padding(.leading, 20)
                            .frame(height: store.ratings[type] == nil ? 76 : 64)
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(RatingType.allCases) { type in
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { rating in
                                ratingButton(type: type, rating: rating)
                            }
                        }
                        .frame(height: store.ratings[type] == nil ? 76 : 64)
                    }
                }
                Spacer()
            }
        }
    }
    
    private func ratingButton(type: RatingType, rating: Int) -> some View {
        let color = store.ratings[type, default: 0] < rating ? AppColor.gray20.color : AppColor.seYellow40.color
        let length: CGFloat = store.ratings[type] == nil ? 36 : 24
        
        return Button {
            store.send(.ratingButtonTapped(type, rating))
        } label: {
            AppIcon.starFill.image
                .foregroundStyle(color)
                .frame(width: length, height: length)
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            previousButton
            nextButton
        }
        .padding(20)
    }
    
    private var previousButton: some View {
        Button {
            store.send(.previousButtonTapped)
        } label: {
            HStack(spacing: 6) {
                Text("이전")
                    .pretendard(.body1Bold, color: .orange40)
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.orange40.color)
            )
        }
    }
    
    private var nextButton: some View {
        Button {
            store.send(.nextButtonTapped)
        } label: {
            HStack(spacing: 6) {
                Text("다음")
                    .pretendard(.body1Bold, color: .white)
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(store.isNextButtonEnabled ? AppColor.orange40.color : AppColor.orange20.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ReviewRatingView(
        store: Store(
            initialState: ReviewRatingFeature.State(
                company: ProposedCompany(
                    id: 1,
                    name: "스타벅스 석촌역점",
                    address: "서울특별시 송파구 백제고분로 358 1층",
                    totalRating: 0
                )
            )
        ) {
            ReviewRatingFeature()
        }
    )
}
