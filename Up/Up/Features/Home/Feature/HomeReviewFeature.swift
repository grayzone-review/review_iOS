//
//  HomeReviewFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/20/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeReviewFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var comments: CommentsWindowFeature.State?
        let category: HomeReviewCategory
        let currentLocation: Location 
        
        var homeReviews = [HomeReview]()
        var companies = [Int: SearchedCompany]()
        var reviews = [Int: Review]()
        var needInitialLoad = true
        var isLoading = false
        var hasNext = true
        var currentPage = 0
        var isAlertShowing = false
        var error: FailResponse?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case comments(PresentationAction<CommentsWindowFeature.Action>)
        case viewAppear
        case loadNext
        case setIsLoading(Bool)
        case setHasNext(Bool)
        case setCurrentPage
        case setHomeReviews([HomeReview])
        case backButtonTapped
        case checkNeedToLoadNext(HomeReview)
        case followButtonTapped(SearchedCompany)
        case follow(id: Int, Bool)
        case likeButtonTapped(Review)
        case like(id: Int, Bool)
        case commentButtonTapped(Review)
        case handleError(Error)
    }
    
    enum CancelID: Hashable {
        case follow(id: Int)
        case like(id: Int)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.homeService) var homeService
    @Dependency(\.reviewService) var reviewService
    @Dependency(\.companyService) var companyService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .comments(.dismiss):
                if let review = state.comments?.review {
                    state.reviews[review.id, default: review].commentCount = review.commentCount
                }
                return .none
                
            case .comments:
                return .none
                
            case .viewAppear:
                guard state.needInitialLoad else { return .none }
                state.needInitialLoad = false
                
                return .send(.loadNext)
                
            case .loadNext:
                guard !state.isLoading else { return .none }
                
                state.isLoading = true
                return .run {
                    [
                        category = state.category,
                        hasNext = state.hasNext,
                        currentPage = state.currentPage,
                        location = state.currentLocation
                    ] send in
                    guard hasNext else {
                        await send(.setIsLoading(false))
                        return
                    }
                    
                    let data = switch category {
                    case .popular:
                        try await homeService.fetchPopularReviews(
                            latitude: location.lat,
                            longitude: location.lng,
                            page: currentPage
                        )
                    case .mainRegion:
                        try await homeService.fetchMainRegionReviews(
                            latitude: location.lat,
                            longitude: location.lng,
                            page: currentPage
                        )
                    case .interestedRegion:
                        try await homeService.fetchInterestedRegionReviews(
                            latitude: location.lat,
                            longitude: location.lng,
                            page: currentPage
                        )
                    }
                    
                    let reviews = data.reviews.map { $0.toDomain() }
                    await send(.setHasNext(data.hasNext))
                    await send(.setHomeReviews(reviews))
                    await send(.setIsLoading(false))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .setIsLoading(isLoading):
                state.isLoading = isLoading
                
                return .none
                
            case let .setHasNext(hasNext):
                state.hasNext = hasNext
                
                return .send(.setCurrentPage)
                
            case .setCurrentPage:
                if state.hasNext {
                    state.currentPage += 1
                }
                
                return .none
                
            case let .setHomeReviews(reviews):
                state.homeReviews += reviews
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case let .checkNeedToLoadNext(homeReview):
                guard let index = state.homeReviews.lastIndex(of: homeReview) else { return .none }
                
                if index == state.homeReviews.count - 2 {
                    return .send(.loadNext)
                } else {
                    return .none
                }
                
            case let .followButtonTapped(company):
                state.companies[company.id, default: company].isFollowed.toggle()
                return .send(.follow(id: company.id, state.companies[company.id, default: company].isFollowed))
                    .debounce(
                        id: CancelID.follow(id: company.id),
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case let .follow(id, isFollowed):
                return .run { send in
                    if isFollowed {
                        try await companyService.createCompanyFollowing(of: id)
                    } else {
                        try await companyService.deleteCompanyFollowing(of: id)
                    }
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .likeButtonTapped(review):
                var newReview = state.reviews[review.id, default: review]
                newReview.isLiked.toggle()
                newReview.likeCount += newReview.isLiked ? 1 : -1
                state.reviews[review.id] = newReview
                return .send(.like(id: review.id, newReview.isLiked))
                    .debounce(
                        id: CancelID.like(id: review.id),
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case let .like(id, isLiked):
                return .run { _ in
                    if isLiked {
                        try await reviewService.createReviewLike(of: id)
                    } else {
                        try await reviewService.deleteReviewLike(of: id)
                    }
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .commentButtonTapped(review):
                state.comments = CommentsWindowFeature.State(review: review)
                return .none
                
            case let .handleError(error):
                if let failResponse = error as? FailResponse {
                    state.error = failResponse
                    state.isAlertShowing = true
                    return .none
                } else {
                    print("❌ error: \(error)")
                    return .none
                }
            }
        }
        .ifLet(\.$comments, action: \.comments) {
            CommentsWindowFeature()
        }
    }
}

struct HomeReviewView: View {
    @Bindable var store: StoreOf<HomeReviewFeature>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.homeReviews) { homeReview in
                    VStack(spacing: 0) {
                        companyCard(homeReview.company)
                        reviewCard(store.reviews[homeReview.review.id, default: homeReview.review])
                        separator
                    }
                    .onAppear {
                        store.send(.checkNeedToLoadNext(homeReview))
                    }
                }
            }
        }.onAppear {
            store.send(.viewAppear)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                IconButton(
                    icon: .arrowLeft
                ) {
                    store.send(.backButtonTapped)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(store.category.title)
                    .pretendard(.h2, color: .gray90)
            }
        }
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
        .sheet(item: $store.scope(state: \.comments, action: \.comments)) { commentsWindowStore in
            CommentsWindowView(store: commentsWindowStore)
        }
    }
    
    private func companyCard(_ company: SearchedCompany) -> some View {
        NavigationLink(
            state: UpFeature.MainPath.State.detail(
                CompanyDetailFeature.State(
                    companyID: company.id
                )
            )
        ) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(company.name)
                                .multilineTextAlignment(.leading)
                                .pretendard(.body1Bold, color: .gray80)
                            Text(company.location)
                                .pretendard(.captionRegular, color: .gray50)
                        }
                        Spacer()
                        followButton(company)
                    }
                    HStack(spacing: 4) {
                        Text(String(company.totalRating.rounded(to: 1)))
                            .pretendard(.h3Bold, color: .gray90)
                        StarRatingView(rating: company.totalRating)
                    }
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("한줄평")
                        .pretendard(.captionBold, color: .gray50)
                        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .background(AppColor.gray10.color)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    if let title = company.reviewTitle {
                        Text(title)
                            .pretendard(.captionRegular, color: .gray70)
                            .padding(.top, 4)
                    }
                    Spacer()
                }
            }
            .padding(20)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColor.gray20.color)
            )
        }
        .padding(20)
            
    }
    
    private func followButton(_ company: SearchedCompany) -> some View {
        Button {
            store.send(.followButtonTapped(company))
        } label: {
            if store.companies[company.id, default: company].isFollowed {
                following
            } else {
                follow
            }
        }
    }
    
    private var following: some View {
        AppIcon.followingFill.image(
            width: 24,
            height: 24,
            appColor: .white
        )
        .padding(4)
        .background(AppColor.orange40.color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var follow: some View {
        AppIcon.followLine.image(
            width: 24,
            height: 24,
            appColor: .orange40
        )
        .padding(4)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.orange40.color)
        }
    }
    
    private func reviewCard(_ review: Review) -> some View {
        ReviewCardView(
            review: review,
            isExpanded: true,
            expansionHandler: { _ in },
            likeButtonAction: { _ in store.send(.likeButtonTapped(review)) },
            commentButtonAction: { _ in store.send(.commentButtonTapped(review)) }
        )
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray10.color)
            .frame(height: 8)
    }
}

#Preview {
    NavigationStack {
        HomeReviewView(
            store: Store(
                initialState: HomeReviewFeature.State(category: .popular, currentLocation: .default)
            ) {
                HomeReviewFeature()
            }
        )
    }
}
