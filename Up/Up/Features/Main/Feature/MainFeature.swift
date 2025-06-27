//
//  MainFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/27/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MainFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case makeReviewButtonTapped
        case tabSelected(Tab)
        case home(HomeFeature.Action)
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    enum Tab {
        case home
        case myPage
    }
    
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
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .home:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MainFeature.Destination.State: Equatable {}

struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>
    
    var body: some View {
        ZStack {
            TabView(selection: $store.selectedTab) {
                home
                    .tag(MainFeature.Tab.home)
                myPage
                    .tag(MainFeature.Tab.myPage)
            }
            
            VStack {
                Spacer()
                tabBar
            }
        }
    }
    
    private var home: some View {
        let homeStore = store.scope(state: \.home, action: \.home)
        
        return HomeView(store: homeStore)
    }
    
    private var myPage: some View {
        Text("마이페이지") // 마이페이지 생성 후 교체
    }
    
    private var tabBar: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(.white)
                .frame(height: 60)
                .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
                .overlay {
                    HStack(spacing: 0) {
                        homeTabButton
                        Spacer()
                        myPageTabButton
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 28)
            makeReviewButton
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.1), radius: 2, y: -2)
        .ignoresSafeArea()
    }
    
    private var homeTabButton: some View {
        let color: AppColor = store.selectedTab == .home ? .orange40 : .gray50
        
        return Button {
            store.send(.tabSelected(.home))
        } label: {
            VStack(spacing: 4) {
                AppIcon.homeLine.image(width: 24, height: 24, appColor: color)
                Text("홈")
                    .pretendard(.captionBold, color: color)
            }
            .frame(width: 52, height: 44)
        }
        .padding(.leading, 50)
    }
    
    private var myPageTabButton: some View {
        let color: AppColor = store.selectedTab == .myPage ? .orange40 : .gray50
        
        return Button {
            store.send(.tabSelected(.myPage))
        } label: {
            VStack(spacing: 4) {
                AppIcon.userLine.image(width: 24, height: 24, appColor: color)
                Text("마이페이지")
                    .pretendard(.captionBold, color: color)
            }
            .frame(width: 52, height: 44)
        }
        .padding(.trailing, 50)
    }
    
    private var makeReviewButton: some View {
        Button {
            store.send(.makeReviewButtonTapped)
        } label: {
            ZStack {
                Circle()
                    .fill(AppColor.orange10.color)
                    .frame(width: 56)
                Circle()
                    .fill(AppColor.orange20.color)
                    .frame(width: 46)
                Circle()
                    .fill(AppColor.orange40.color)
                    .frame(width: 36)
                AppIcon.followLine.image(width: 24, height: 24, appColor: .white)
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.review, action: \.destination.review)
        ) { reviewStore in
            ReviewMakingView(store: reviewStore)
        }
    }
}

#Preview {
    NavigationStack {
        MainView(
            store: Store(
                initialState: MainFeature.State()
            ) {
                MainFeature()
            }
        )
    }
}
