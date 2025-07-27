//
//  MyReviewTabFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MyReviewTabFeature {
    @ObservableState
    struct State: Equatable {
        var reviews = [ActivityReview]()
        var needInitialLoad = true
        var isLoading = false
        var hasNext = true
        var currentPage = 0
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case viewAppear
        case loadNext
        case setIsLoading(Bool)
        case setHasNext(Bool)
        case setCurrentPage
        case setReviews([ActivityReview])
        case checkNeedToLoadNext(ActivityReview)
        case delegate(Delegate)
        
        enum Delegate {
            case alert(Error)
        }
    }
    
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return.none
                
            case .viewAppear:
                guard state.needInitialLoad else { return .none }
                state.needInitialLoad = false
                
                return .send(.loadNext)
                
            case .loadNext:
                guard !state.isLoading else { return .none }
                
                state.isLoading = true
                return .run {
                    [
                        hasNext = state.hasNext,
                        currentPage = state.currentPage
                    ] send in
                    guard hasNext else {
                        await send(.setIsLoading(false))
                        return
                    }
                    
                    let data = try await homeService.fetchMyReviews(page: currentPage)
                    let reviews = data.reviews.map { $0.toDomain() }
                    
                    await send(.setHasNext(data.hasNext))
                    await send(.setReviews(reviews))
                    await send(.setIsLoading(false))
                } catch: { error, send in
                    await send(.delegate(.alert(error)))
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
                
            case let .setReviews(reviews):
                state.reviews += reviews
                return .none
                
            case let .checkNeedToLoadNext(review):
                guard let index = state.reviews.lastIndex(of: review) else { return .none }
                
                if index == state.reviews.count - 2 {
                    return .send(.loadNext)
                } else {
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

struct MyReviewTabView: View {
    @Bindable var store: StoreOf<MyReviewTabFeature>
    
    var body: some View {
        myReview
            .onAppear {
                store.send(.viewAppear)
            }
    }
    
    @ViewBuilder
    private var myReview: some View {
        if store.reviews.isEmpty {
            empty
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.reviews) { review in
                        VStack(spacing: 0) {
                            NavigationLink(
                                state: UpFeature.MainPath.State.detail(
                                    CompanyDetailFeature.State(
                                        companyID: review.companyID
                                    )
                                )
                            ) {
                                ActivityReviewCardView(review: review)
                            }
                            Divider()
                        }
                        .onAppear {
                            store.send(.checkNeedToLoadNext(review))
                        }
                    }
                }
            }
        }
    }
    
    private var empty: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.chatSecondFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("작성된 리뷰가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
}

#Preview {
    MyReviewTabView(
        store: Store(
            initialState: MyReviewTabFeature.State()
        ) {
            MyReviewTabFeature()
        }
    )
}
