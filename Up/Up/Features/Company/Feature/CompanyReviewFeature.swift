//
//  ReviewCardFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CompanyReviewFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var comments: CommentsWindowFeature.State?
        let companyID: Int
        var reviews: [Review] = []
        var hasNextPage = true
        var isLoading = false
        var isReviewExpanded = [Int: Bool]()
        
        var loadPoint: Review? {
            guard reviews.count > 3 else {
                return nil
            }
            
            return reviews[reviews.count - 3]
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case comments(PresentationAction<CommentsWindowFeature.Action>)
        case viewAppear
        case loadReivews
        case reviewsFetched(ReviewsBody)
        case reviewWritten(Review)
        case reviewCardExpansionButtonTapped(Review)
        case likeButtonTapped(Review)
        case like(Review)
        case commentButtonTapped(Review)
        case delegate(Delegate)
        
        enum Delegate {
            case alert(Error)
        }
    }
    
    enum CancelID {
        case like
    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.companyService) var companyService
    @Dependency(\.reviewService) var reviewService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .comments(.dismiss):
                if let review = state.comments?.review,
                   let index = state.reviews.firstIndex(where: { $0.id == review.id }) {
                    state.reviews[index] = review
                }
                return .none
                
            case .comments:
                return .none
                
            case .viewAppear:
                return .send(.loadReivews)
                
            case .loadReivews:
                guard state.isLoading == false,
                      state.hasNextPage else {
                    return .none
                }
                
                state.isLoading = true
                
                return .run { [companyID = state.companyID, page = state.reviews.count / 10] send in
                    let data = try await companyService.fetchReviews(of: companyID, page: page)
                    await send(.reviewsFetched(data))
                } catch: { error, send in
                    await send(.delegate(.alert(error)))
                }
                
            case let .reviewsFetched(body):
                state.reviews += body.reviews.map { $0.toDomain() }
                state.hasNextPage = body.hasNext
                state.isLoading = false
                return .none
                
            case let .reviewWritten(review):
                state.reviews.insert(review, at: 0)
                return .none
                
            case let .reviewCardExpansionButtonTapped(review):
                let isExpanded = state.isReviewExpanded[review.id, default: false]
                state.isReviewExpanded[review.id] = !isExpanded
                return .none
                
            case let .likeButtonTapped(review):
                guard let index = state.reviews.firstIndex(where: { $0.id == review.id }) else {
                    return .none
                }
                state.reviews[index].likeCount += state.reviews[index].isLiked ? -1 : 1
                state.reviews[index].isLiked.toggle()
                return .send(.like(review))
                    .debounce(
                        id: CancelID.like,
                        for: 1,
                        scheduler: mainQueue
                    )
                
            case let .like(review):
                return .run { send in
                    if review.isLiked {
                        try await reviewService.createReviewLike(of: review.id)
                    } else {
                        try await reviewService.deleteReviewLike(of: review.id)
                    }
                } catch: { error, send in
                    await send(.delegate(.alert(error)))
                }
                
            case let .commentButtonTapped(review):
                state.comments = CommentsWindowFeature.State(review: review)
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$comments, action: \.comments) {
            CommentsWindowFeature()
        }
    }
}

struct CompanyReviewView: View {
    @Bindable var store: StoreOf<CompanyReviewFeature>
    
    var body: some View {
        review
            .onAppear {
                store.send(.viewAppear)
            }
            .sheet(item: $store.scope(state: \.comments, action: \.comments)) { commentsWindowStore in
                CommentsWindowView(store: commentsWindowStore)
            }
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
            AppIcon.reviewFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("아직 등록된 리뷰가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
        }
        .frame(height: 290)
    }
    
    private var reviewList: some View {
        LazyVStack(spacing: 0) {
            ForEach(store.reviews) { review in
                ReviewCardView(
                    review: review,
                    isExpanded: store.isReviewExpanded[review.id, default: false],
                    expansionHandler: { _ in store.send(.reviewCardExpansionButtonTapped(review)) },
                    likeButtonAction: { _ in store.send(.likeButtonTapped(review)) },
                    commentButtonAction: { _ in store.send(.commentButtonTapped(review)) }
                )
                .onAppear {
                    if store.loadPoint == review {
                        store.send(.loadReivews)
                    }
                }
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
    
}
