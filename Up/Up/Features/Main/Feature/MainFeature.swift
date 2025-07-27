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
        @Shared(.user) var user
        var selectedTab: Tab = .home
        var home = HomeFeature.State()
        var myPage = MyPageFeature.State()
        var isAlertShowing = false
        var error: FailResponse?
        var isResignAlertShowing = false
        var isSignOutAlertShowing = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case viewAppear
        case fetchUser
        case userFetched(User)
        case makeReviewButtonTapped
        case tabSelected(Tab)
        case home(HomeFeature.Action)
        case myPage(MyPageFeature.Action)
        case handleError(Error)
        case resign
        case signOut
    }
    
    @Reducer
    enum Destination {
        case review(ReviewMakingFeature)
    }
    
    enum Tab {
        case home
        case myPage
    }
    
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .destination:
                return .none
                
            case .viewAppear:
                guard state.user == nil else {
                    return .none
                }
                
                return .run { send in
                    await send(.fetchUser)
                }
                
            case .fetchUser:
                guard state.user == nil else {
                    return .none
                }
                
                return .run { send in
                    let data = try await homeService.fetchUser()
                    let user = data.toDomain()
                    
                    await send(.userFetched(user))
                } catch: { error, send in
                    await send(.handleError(error))
                }
                
            case let .userFetched(user):
                state.$user.withLock {
                    $0 = user
                }
                return .none
                
            case .makeReviewButtonTapped:
                state.destination = .review(ReviewMakingFeature.State())
                return .none
                
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case let .home(.delegate(.alert(error))):
                return .send(.handleError(error))
                
            case .home:
                return .none
                
            case let .myPage(.delegate(.alert(error))):
                return .send(.handleError(error))
                
            case let .myPage(.delegate(.setIsResignAlertShowing(isResignAlertShowing))):
                state.isResignAlertShowing = isResignAlertShowing
                return .none
                
            case let .myPage(.delegate(.setIsSignOutAlertShowing(isSignOutAlertShowing))):
                state.isSignOutAlertShowing = isSignOutAlertShowing
                return .none
                
            case .myPage:
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
                
            case .resign:
                return .send(.myPage(.resign))
                
            case .signOut:
                return .send(.myPage(.signOut))
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MainFeature.Destination.State: Equatable {}

extension SharedKey where Self == FileStorageKey<User?>.Default {
    static var user: Self {
        Self[.fileStorage(.documentsDirectory.appending(component: "user.json")), default: nil]
    }
}

struct MainView: View {
    @Bindable var store: StoreOf<MainFeature>
    
    init(store: StoreOf<MainFeature>) {
        self.store = store
        store.send(.viewAppear)
    }
    
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
        .onAppear {
            store.send(.viewAppear)
        }
        .appAlert($store.isAlertShowing, isSuccess: false, message: store.error?.message ?? "")
        .actionAlert(
            $store.isResignAlertShowing,
            icon: .infoFill,
            title: "회원 탈퇴",
            message: "탈퇴 후, 현재 계정으로 작성한 글, 댓글등을 수정하거나 삭제할 수 없습니다. 지금 탈퇴하시겠습니까?",
            preferredText: "탈퇴하기"
        ) {
            store.send(.resign)
        }
        .actionAlert(
            $store.isSignOutAlertShowing,
            title: "로그 아웃",
            message: "로그아웃 하시겠습니까?",
            preferredText: "로그아웃"
        ) {
            store.send(.signOut)
        }
    }
    
    private var home: some View {
        let homeStore = store.scope(state: \.home, action: \.home)
        
        return HomeView(store: homeStore)
    }
    
    private var myPage: some View {
        let myPageStore = store.scope(state: \.myPage, action: \.myPage)
        
        return MyPageView(store: myPageStore)
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
