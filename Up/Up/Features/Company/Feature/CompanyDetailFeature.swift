//
//  CompanyDetailFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CompanyDetailFeature {
    @ObservableState
    struct State: Equatable {
        let companyID: Int
        var company: Company?
        @Shared var reviews: IdentifiedArrayOf<Review>
    }
    
    enum Action {
        case appear
        case companyInformationFetched(Company)
        case companyReviewsFetched([Review])
        case backButtonTapped
        case followButtonTapped
        case follow
        case makeReviewButtonTapped
    }
    
    enum CancelID {
        case follow
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.companyService) var service
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appear :
                return .run { [companyID = state.companyID] send in
                    let data = try await service.fetchCompany(of: companyID)
                    let company = data.toDomain()
                    await send(.companyInformationFetched(company))
                }
                
            case let .companyInformationFetched(company):
                state.company = company
                return .run { [companyID = state.companyID] send in
                    let data = try await service.fetchReviews(of: companyID)
                    let reviews = data.reivews.map { $0.toDomain() }
                    await send(.companyReviewsFetched(reviews))
                }
                
            case let .companyReviewsFetched(reviews):
                state.$reviews.withLock { $0 += reviews }
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case .followButtonTapped:
                state.company?.isFollowed.toggle()
                return .send(.follow)
                    .debounce(
                        id: CancelID.follow,
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case .follow:
                return .run { [company = state.company] _ in
                    guard let company else {
                        return
                    }
                    
                    if company.isFollowed {
                        try await service.createCompanyFollowing(of: company.id)
                    } else {
                        try await service.deleteCompanyFollowing(of: company.id)
                    }
                }
                
            case .makeReviewButtonTapped:
                return .none
            }
        }
    }
}

struct CompanyDetailView: View {
    @Bindable var store: StoreOf<CompanyDetailFeature>
    
    init(store: StoreOf<CompanyDetailFeature>) {
        self.store = store
        store.send(.appear)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                information
                interaction
                map
            }
            .padding(EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20))
            
            separator
            review
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    AppIcon.arrowLeft.image
                        .foregroundStyle(AppColor.gray90.color)
                        .frame(width: 24, height: 24)
                        .padding(10)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(store.company?.name ?? "")
                    .pretendard(.h2, color: .gray90)
            }
        }
    }
    
    private var information: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.company?.name ?? "")
                    .pretendard(.h3, color: .gray90)
                
                Text(store.company?.address.displayText ?? "")
                    .pretendard(.captionRegular, color: .gray50)
            }
            HStack(spacing: 4) {
                AppIcon.starFill.image
                    .foregroundStyle(AppColor.seYellow40.color)
                    .frame(width: 24, height: 24)
                Text(String(store.company?.totalRating.rounded(to: 1) ?? 0))
                    .pretendard(.h1, color: .gray90)
            }
        }
    }
    
    private var interaction: some View {
        HStack(spacing: 12) {
            followButton
            makeReviewButton
        }
        .frame(maxWidth: .infinity, maxHeight: 48)
    }
    
    @ViewBuilder
    var followButton: some View {
        let isFollowed = store.company?.isFollowed == true
        
        Button {
            store.send(.followButtonTapped)
        } label: {
            HStack(spacing: 6) {
                (isFollowed ? AppIcon.followingFill : .followLine).image
                    .frame(width: 16, height: 16)
                    .foregroundStyle(isFollowed ? AppColor.white.color : AppColor.orange40.color)
                Text("팔로우")
                    .pretendard(.body1Bold, color: isFollowed ? .white : .orange40)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(isFollowed ? AppColor.orange40.color : AppColor.white.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.orange40.color)
            )
        }
    }
    
    var makeReviewButton: some View {
        Button {
            store.send(.makeReviewButtonTapped)
        } label: {
            HStack(spacing: 6) {
                AppIcon.penFill.image
                    .frame(width: 16, height: 16)
                    .foregroundStyle(AppColor.white.color)
                Text("리뷰 작성")
                    .pretendard(.body1Bold, color: .white)
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(AppColor.orange40.color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    var map: some View {
        Group {
            if let company = store.company {
                KakaoMapCardView(coordinate: company.coordinate)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(height: 188)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray20.color)
            .frame(height: 8)
    }
    
    @ViewBuilder
    private var review: some View {
        if store.reviews.isEmpty {
            empty
        } else {
            reviewList
        }
    }
    
    private var empty: some View {
        VStack(alignment: .center, spacing: 12) {
            AppIcon.reviewFill.image
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(AppColor.gray30.color)
            Text("아직 등록된 리뷰가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
        }
        .frame(height: 290)
    }
    
    private var reviewList: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(store.$reviews)) { $review in
                ReivewCardView(
                    store: Store(
                        initialState: ReviewCardFeature.State(
                            review: $review
                        )
                    ) {
                        ReviewCardFeature()
                    }
                )
                divider
            }
        }
    }
    
    private var divider: some View {
        Divider()
            .background(AppColor.gray20.color)
    }
}

#Preview {
    NavigationStack {
        CompanyDetailView(
            store: Store(
                initialState: CompanyDetailFeature.State(
                    companyID: 1,
                    reviews: Shared(value: [])
                )
            ) {
                CompanyDetailFeature()
            }
        )
    }
}
