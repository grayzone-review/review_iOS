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
        var homeReviews = [HomeReview]()
        var companies = [Int: SearchedCompany]()
        var reviews = [Int: Review]()
        var needInitialLoad = true
        var isLoading = false
        var hasNext = true
        var currentPage = 0
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case comments(PresentationAction<CommentsWindowFeature.Action>)
        case viewInit
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
        case handleError(any Error)
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
                
            case .viewInit:
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
                        currentPage = state.currentPage
                    ] send in
                    guard hasNext else {
                        await send(.setIsLoading(false))
                        return
                    }
                    
                    do {
                        let data = switch category {
                        case .popular:
                            try await homeService.fetchPopularReviews(
                                latitude: 37.5665,
                                longitude: 126.9780,
                                page: currentPage
                            )
                        case .mainRegion:
                            try await homeService.fetchMainRegionReviews(
                                latitude: 37.5665,
                                longitude: 126.9780,
                                page: currentPage
                            )
                        case .interestedRegion:
                            try await homeService.fetchInterestedRegionReviews(
                                latitude: 37.5665,
                                longitude: 126.9780,
                                page: currentPage
                            )
                        }
                        
                        let reviews = data.reviews.map { $0.toDomain() }
                        await send(.setHasNext(data.hasNext))
                        await send(.setHomeReviews(reviews))
                        await send(.setIsLoading(false))
                    } catch {
                        await send(.handleError(error))
                    }
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
                    do {
                        if isFollowed {
                            try await companyService.createCompanyFollowing(of: id)
                        } else {
                            try await companyService.deleteCompanyFollowing(of: id)
                        }
                    } catch {
                        await send(.handleError(error))
                    }
                }
                
            case let .likeButtonTapped(review):
                state.reviews[review.id, default: review].isLiked.toggle()
                let isLiked = state.reviews[review.id, default: review].isLiked
                state.reviews[review.id, default: review].likeCount += isLiked ? 1 : -1
                return .send(.like(id: review.id, state.reviews[review.id, default: review].isLiked))
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
                }
                
            case let .commentButtonTapped(review):
                state.comments = CommentsWindowFeature.State(review: review)
                return .none
                
            case let .handleError(error):
                // TODO: - Handling Error
                print("❌ error: \(error)")
                
                return .none
            }
        }
        .ifLet(\.$comments, action: \.comments) {
            CommentsWindowFeature()
        }
    }
}

struct HomeReviewView: View {
    @Bindable var store: StoreOf<HomeReviewFeature>
    
    init(store: StoreOf<HomeReviewFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.homeReviews) { homeReview in
                    VStack(spacing: 0) {
                        companyCard(homeReview.company)
                        reviewCard(homeReview.review)
                        separator
                    }
                    .onAppear {
                        store.send(.checkNeedToLoadNext(homeReview))
                    }
                }
            }
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
    }
    
    private func companyCard(_ company: SearchedCompany) -> some View {
        NavigationLink(
            state: UpFeature.Path.State.detail(
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
                            .pretendard(.h3, color: .gray90)
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
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                header(review)
                rating(review)
            }
            VStack(alignment: .leading, spacing: 4) {
                title(review)
                content(review)
                interaction(review)
            }
        }
        .padding(EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20))
        .sheet(item: $store.scope(state: \.comments, action: \.comments)) { commentsWindowStore in
            CommentsWindowView(store: commentsWindowStore)
        }
    }
    
    private func header(_ review: Review) -> some View {
        HStack(spacing: 8) {
            Text(review.reviewer)
            divider
            Text(review.job)
            divider
            Text(review.employmentPeriod)
            divider
            Text(DateFormatter.reviewCardFormat.string(from: review.creationDate))
            Spacer()
        }
        .pretendard(.captionRegular, color: .gray50)
        .frame(maxHeight: 18)
    }
    
    private var divider: some View {
        Divider()
            .background(AppColor.gray20.color)
    }
    
    private func rating(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(review.rating.displayText)
                    .pretendard(.h3, color: .gray90)
                StarRatingView(rating: review.rating.totalRating)
            }
            ratings(review)
        }
    }
    
    private func ratings(_ review: Review) -> some View {
        HStack(alignment: .top) {
            VStack(spacing: 20) {
                rating("급여", review.rating.salary)
                rating("복지", review.rating.welfare)
                rating("워라벨", review.rating.workLifeBalance)
            }
            .frame(width: 118)
            Spacer()
            VStack(spacing: 20) {
                rating("사내문화", review.rating.companyCulture)
                rating("경영진", review.rating.management)
            }
            .frame(width: 118)
        }
        .padding(20)
        .background(AppColor.gray10.color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColor.gray20.color)
        )
    }
    
    private func rating(_ item: String, _ rating: Double) -> some View {
        HStack {
            Text(item)
                .pretendard(.captionRegular, color: .gray50)
            Spacer()
            StarRatingView(rating: rating, length: 12, spacing: 2)
        }
    }
    
    private func title(_ review: Review) -> some View {
        Text(review.title.withZeroWidthSpaces)
            .pretendard(.h3, color: .gray90)
    }
    
    private func content(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            reviewPoint(review, .advantage)
            reviewPoint(review, .disadvantage)
            reviewPoint(review, .managementFeedback)
        }
    }
    
    private func reviewPoint(_ review: Review, _ point: Review.Point) -> some View {
        let text = switch point {
        case .advantage:
            review.advantagePoint
        case .disadvantage:
            review.disadvantagePoint
        case .managementFeedback:
            review.managementFeedback
        }
        
        return HStack(alignment: .top, spacing: 12) {
            Text(point.keyword)
                .pretendard(.captionBold, color: point.accentColor)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                .background(point.backgroundColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(text.withZeroWidthSpaces)
                .pretendard(.body1Regular, color: .gray80)
        }
        .padding(.vertical, 16)
    }
    
    private func interaction(_ review: Review) -> some View {
        HStack(spacing: 8) {
            likeButton(review)
            replyButton(review)
        }
    }
    
    private func likeButton(_ review: Review) -> some View {
        let review = store.reviews[review.id, default: review]
        
        return Button {
            store.send(.likeButtonTapped(review))
        } label: {
            HStack(alignment: .center, spacing: 0) {
                (review.isLiked ? AppIcon.heartFill : .heartLine).image(
                    width: 24,
                    height: 24,
                    appColor: review.isLiked ? .seRed50 : .black
                )
                .padding(10)
                Text(String(review.likeCount))
                    .pretendard(.body1Bold)
            }
        }
    }
    
    private func replyButton(_ review: Review) -> some View {
        Button {
            store.send(.commentButtonTapped(review))
        } label: {
            HStack(alignment: .center, spacing: 0) {
                AppIcon.chatLine.image(
                    width: 24,
                    height: 24,
                    appColor: .black
                )
                .padding(10)
                Text(String(store.reviews[review.id, default: review].commentCount))
                    .pretendard(.body1Bold)
            }
        }
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
                initialState: HomeReviewFeature.State(category: .popular)
            ) {
                HomeReviewFeature()
            }
        )
    }
}
