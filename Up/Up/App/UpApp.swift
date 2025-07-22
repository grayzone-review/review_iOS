//
//  UpApp.swift
//  UpApp
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK
import KakaoSDKCommon
import KakaoSDKAuth

@Reducer
struct UpFeature {
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var oauthLogin = OAuthLoginFeature.State()
        var path = StackState<Path.State>()
        var main = MainFeature.State()
        var isFirstLaunch = true
        var isBootstrapping = true
        
        init() {
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            
            // 앱 설치 후 첫 실행이면 키체인을 초기화합니다.
            if !hasLaunchedBefore {
                Task {
                    await SecureTokenManager.shared.clearTokens()
                }
            }
            
            isFirstLaunch = hasLaunchedBefore != true
        }
    }
    
    enum Action {
        case appLaunched
        case initKakaoSDK
        case setIsFirstLaunch
        case endBootstrap
        case oauthLogin(OAuthLoginFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case path(StackActionOf<Path>)
        case main(MainFeature.Action)
    }
    
    @Reducer
    enum Path {
        case signUp(SignUpFeature)
        case searchArea(SearchAreaFeature)
        case activity(MyActivityFeature)
        case homeReview(HomeReviewFeature)
        case search(SearchCompanyFeature)
        case detail(CompanyDetailFeature)
        case report(ReportFeature)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }

        Scope(state: \.oauthLogin, action: \.oauthLogin) {
            OAuthLoginFeature()
        }

        Reduce { state, action in
            switch action {
            case .appLaunched:
                return .run { send in
                    await send(.initKakaoSDK)
                    await send(.setIsFirstLaunch)
                    await send(.endBootstrap)
                }
                
            case .initKakaoSDK:
                guard
                    let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String
                else {
                  fatalError("Info.plist에서 Key 정보를 읽어오지 못했습니다.")
                }
                
                SDKInitializer.InitSDK(appKey: kakaoAppKey)
                return .none
                
            case .setIsFirstLaunch:
                let hasLaunchedBefore = try? userDefaultsService.fetch(key: "hasLaunchedBefore", type: Bool.self)
                
                state.isFirstLaunch = hasLaunchedBefore != true
                return .none
                
            case .endBootstrap:
                state.isBootstrapping = false
                return .none
                
            case .onboarding(.delegate(.startButtonTapped)):
                try? userDefaultsService.save(key: "hasLaunchedBefore", value: true)
                state.isFirstLaunch = false
                
                return .none
            case .onboarding:
                return .none
            case .oauthLogin(.delegate(.tokenReceived)):
                state.path.append(.signUp(SignUpFeature.State()))
                
                return .none
            case .oauthLogin:
                return .none
            case .path:
                return .none
                
            case .main:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension UpFeature.Path.State: Equatable {}

struct UpView: View {
    @Bindable var store: StoreOf<UpFeature>
    
    init(store: StoreOf<UpFeature>) {
        self.store = store
        store.send(.appLaunched)
    }
    
    var body: some View {
        if store.isBootstrapping {
            launchScreen
        } else if store.isFirstLaunch {
            onboarding
        } else {
            main
        }
    }
    
    private var launchScreen: some View {
        Text("Launch Screen")
    }
    
    private var onboarding: some View {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                OAuthLoginView(store: store.scope(state: \.oauthLogin, action: \.oauthLogin))
            } destination: { store in
                switch store.case {
                case let .signUp(store):
                    SignUpView(store: store)
                case let .searchArea(store):
                    SearchAreaView(store: store)
                }
    }
    
    private var main: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MainView(store: store.scope(state: \.main, action: \.main))
        } destination: { store in
            switch store.case {
            case let .activity(activityStore):
                MyActivityView(store: activityStore)
                
            case let .homeReview(homeReviewStore):
                HomeReviewView(store: homeReviewStore)
                
            case let .search(searchStore):
                SearchCompanyView(store: searchStore)
                
            case let .detail(detailStore):
                CompanyDetailView(store: detailStore)
                
            case let .report(reportStore):
                ReportView(store: reportStore)
            }
        }
    }
}

@main
struct UpApp: App {
    @MainActor
    static let store = Store(initialState: UpFeature.State()) {
        UpFeature()
    }
    
    init() {
        guard
            let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String
        else {
          fatalError("Info.plist에서 Key 정보를 읽어오지 못했습니다.")
        }
        
        SDKInitializer.InitSDK(appKey: kakaoAppKey)
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            UpView(store: Self.store)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

#Preview {
    UpView(
        store: Store(
            initialState: UpFeature.State()
        ) {
            UpFeature()
        }
    )
}
