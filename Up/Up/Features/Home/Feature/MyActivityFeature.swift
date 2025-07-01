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
        var selectedTab: Tab
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case makeReviewButtonTapped
        case backButtonTapped
        case tabSelected(Tab)
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
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .destination:
                return .none
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case .backButtonTapped:
                return .run { _ in await dismiss() }
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MyActivityFeature.Destination.State: Equatable {}

struct MyActivityView: View {
    @Bindable var store: StoreOf<MyActivityFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            activityCounts
            seperator
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
                Text("건디") // 계정 정보 받아 사용
                    .pretendard(.h2, color: .gray90)
            }
        }
    }
    
    private var activityCounts: some View {
        HStack {
            VStack(spacing: 4) {
                Text("2")
                    .pretendard(.h3, color: .orange40)
                Text("작성 리뷰 수")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
            Spacer()
            VStack(spacing: 4) {
                Text("2")
                    .pretendard(.h3, color: .orange40)
                Text("도움이 됐어요")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
            Spacer()
            VStack(spacing: 4) {
                Text("3")
                    .pretendard(.h3, color: .orange40)
                Text("즐겨찾기")
                    .pretendard(.body1Bold, color: .gray90)
            }
            .frame(width: 87)
        }
        .padding(20)
    }
    
    private var seperator: some View {
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
        emptyReview // API 확정되면 UI 추가하여 스크롤 뷰 작성
    }
    
    private var emptyReview: some View {
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
    
    private var activityTab: some View {
        emptyActivity // API 확정되면 UI 추가하여 스크롤 뷰 작성
    }
    
    private var emptyActivity: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.chatSecondFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("좋아요 또는 댓글을 남긴\n리뷰가 없습니다.")
                .multilineTextAlignment(.center)
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
    }
    
    private var followingTab: some View {
        emptyFollowing // API 확정되면 UI 추가하여 스크롤 뷰 작성
    }
    
    private var emptyFollowing: some View {
        VStack(spacing: 12) {
            Spacer()
            AppIcon.followingFill.image(
                width: 48,
                height: 48,
                appColor: .gray30
            )
            Text("팔로우 한 업체가 없습니다.")
                .pretendard(.body1Regular, color: .gray50)
            Spacer()
        }
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
                initialState: MyActivityFeature.State(
                    selectedTab: .review
                )
            ) {
                MyActivityFeature()
            }
        )
    }
}
