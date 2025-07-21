//
//  MyActivityFeature.swift
//  Up
//
//  Created by Jun Young Lee on 7/2/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MyActivityFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        @Shared(.user) var user
        var counts: InteractionCounts?
        var selectedTab: Tab
        var myReview = MyReviewTabFeature.State()
        var interactedReview = InteractedReviewTabFeature.State()
        var followedCompany = FollowedCompanyTabFeature.State()
        
        var userName: String {
            user?.nickname ?? "사용자"
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case viewInit
        case countsFetched(InteractionCounts)
        case makeReviewButtonTapped
        case backButtonTapped
        case tabSelected(Tab)
        case myReview(MyReviewTabFeature.Action)
        case interactedReview(InteractedReviewTabFeature.Action)
        case followedCompany(FollowedCompanyTabFeature.Action)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    enum Tab {
        case review
        case activity
        case following
        
        var title: String {
            switch self {
            case .review:
                "리뷰"
            case .activity:
                "관심 리뷰"
            case .following:
                "즐겨찾기"
            }
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.myReview, action: \.myReview) {
            MyReviewTabFeature()
        }
        Scope(state: \.interactedReview, action: \.interactedReview) {
            InteractedReviewTabFeature()
        }
        Scope(state: \.followedCompany, action: \.followedCompany) {
            FollowedCompanyTabFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .destination:
                return .none
                
            case .viewInit:
                guard state.counts == nil else {
                    return .none
                }
                
                return .run { send in
                    let data = try await homeService.fetchInteractionCounts()
                    let counts = data.toDomain()
                    
                    await send(.countsFetched(counts))
                }
                
            case let .countsFetched(counts):
                state.counts = counts
                return .none
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .myReview:
                return .none
                
            case .interactedReview:
                return .none
                
            case .followedCompany:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MyActivityFeature.Destination.State: Equatable {}

struct MyActivityView: View {
    @Bindable var store: StoreOf<MyActivityFeature>
    
    init(store: StoreOf<MyActivityFeature>) {
        self.store = store
        store.send(.viewInit)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            activityCounts
            separator
            tabBar
            TabView(selection: $store.selectedTab) {
                reviewTab
                    .tag(MyActivityFeature.Tab.review)
                activityTab
                    .tag(MyActivityFeature.Tab.activity)
                followingTab
                    .tag(MyActivityFeature.Tab.following)
            }
            .tabViewStyle(.page)
            makeReviewButton
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
                Text(store.userName)
                    .pretendard(.h2, color: .gray90)
            }
        }
    }
    
    private var activityCounts: some View {
        HStack {
            VStack(spacing: 4) {
                Text(String(store.counts?.myReviewCount ?? 0))
                    .pretendard(.h3Bold, color: .orange40)
                Text("작성 리뷰 수")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
            Spacer()
            VStack(spacing: 4) {
                Text(String(store.counts?.interactedReviewCount ?? 0))
                    .pretendard(.h3Bold, color: .orange40)
                Text("도움이 됐어요")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
            Spacer()
            VStack(spacing: 4) {
                Text(String(store.counts?.followedCompanyCount ?? 0))
                    .pretendard(.h3Bold, color: .orange40)
                Text("즐겨찾기")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
        }
        .padding(20)
    }
    
    private var separator: some View {
        Rectangle()
            .foregroundStyle(AppColor.gray10.color)
            .frame(height: 8)
    }
    
    private var tabBar: some View {
        ZStack(alignment: .bottom) {
            Divider()
            HStack(spacing: 0) {
                tabButton(.review)
                tabButton(.activity)
                tabButton(.following)
            }
            .frame(height: 31)
            .padding([.top, .horizontal], 20)
        }
    }
    
    private func tabButton(_ tab: MyActivityFeature.Tab) -> some View {
        let isSelected = store.selectedTab == tab
        
        return Button {
            store.send(.tabSelected(tab))
        } label: {
            VStack(spacing: 6) {
                Text(tab.title)
                    .pretendard(
                        isSelected ? .body1Bold : .body1Regular,
                        color: isSelected ? .gray90 : .gray50
                    )
                    Rectangle()
                    .frame(height: 4)
                    .foregroundStyle(isSelected ? AppColor.orange40.color : .clear)
            }
        }
    }
    
    private var reviewTab: some View {
        let myReviewStore = store.scope(state: \.myReview, action: \.myReview)
        return MyReviewTabView(store: myReviewStore)
    }
    
    private var activityTab: some View {
        let interactedReviewStore = store.scope(state: \.interactedReview, action: \.interactedReview)
        return InteractedReviewTabView(store: interactedReviewStore)
    }
    
    private var followingTab: some View {
        let followedCompanyStore = store.scope(state: \.followedCompany, action: \.followedCompany)
        return FollowedCompanyTabView(store: followedCompanyStore)
    }
    
    private var makeReviewButton: some View {
        AppButton(
            style: .fill,
            size: .large,
            text: "리뷰 작성하러 가기"
        ) {
            store.send(.makeReviewButtonTapped)
        }
        .padding(EdgeInsets(top: 11, leading: 24, bottom: 11, trailing: 24))
        .fullScreenCover(
            item: $store.scope(state: \.destination?.review, action: \.destination.review)
        ) { reviewStore in
            ReviewMakingView(store: reviewStore)
        }
    }
}

#Preview {
    NavigationStack {
        MyActivityView(
            store: Store(
                initialState: MyActivityFeature.State(selectedTab: .review)
            ) {
                MyActivityFeature()
            }
        )
    }
}
