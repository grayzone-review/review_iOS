//
//  ReviewMakingFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/19/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ReviewMakingFeature {
    @ObservableState
    struct State: Equatable {
        var review: Review.State?
        var reviewStates: [Review.State] = []
        
        init(company: Company? = nil) {
            var injectedCompany: ProposedCompany?
            
            if let company {
                injectedCompany = ProposedCompany(
                    id: company.id,
                    name: company.name,
                    address: company.address.displayText,
                    totalRating: company.totalRating
                )
            }
            
            let reviewInformationState: Review.State = .information(ReviewInformationFeature.State(company: injectedCompany))
            
            reviewStates.append(reviewInformationState)
            review = reviewInformationState
        }
        
        var currentPageText: AttributedString {
            let isLast = reviewStates.count == 3
            var attributedString = AttributedString("\(reviewStates.count)/3")
            
            attributedString.foregroundColor = isLast ? AppColor.orange40.color : AppColor.gray50.color
            attributedString.font = Typography.captionBold.font
            
            if let range = attributedString.range(of: "\(reviewStates.count)") {
                attributedString[range].foregroundColor = AppColor.orange40.color
            }
            
            return attributedString
        }
        
        var progressBarScale: Double {
            Double(reviewStates.count) / 3
        }
    }
    
    enum Action {
        case closeButtonTapped
        case review(Review.Action)
    }
    
    @Reducer
    enum Review {
        case information(ReviewInformationFeature)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                return .run { _ in await dismiss() }
                
            case .review(.information(.delegate(.nextButtonTapped))):
                return .none
                
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

struct ReviewMakingView: View {
    @Bindable var store: StoreOf<ReviewMakingFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                progressBar
                bodyArea
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.send(.closeButtonTapped)
                    } label: {
                        AppIcon.closeLine.image
                            .foregroundStyle(AppColor.gray90.color)
                            .frame(width: 24, height: 24)
                            .padding(10)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("리뷰 작성")
                        .pretendard(.h2, color: .gray90)
                }
            }
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(AppColor.gray10.color)
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: geometry.size.width * store.progressBarScale)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppColor.orange30.color,
                                    AppColor.orange40.color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
            }
            .frame(height: 6)
            Text(store.currentPageText)
        }
        .padding(
            EdgeInsets(
                top: 16,
                leading: 20,
                bottom: 16,
                trailing: 20
            )
        )
    }
    
    @ViewBuilder
    private var bodyArea: some View {
        switch store.reviewStates.count {
        default:
            Spacer()
        }
    }
}

#Preview {
    ReviewMakingView(
        store: Store(
            initialState: ReviewMakingFeature.State()
        ) {
            ReviewMakingFeature()
        }
    )
    
}
