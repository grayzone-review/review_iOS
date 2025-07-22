//
//  UpApp.swift
//  UpApp
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK

@Reducer
struct UpFeature {
    @Reducer
    enum Path {
        case detail(CompanyDetailFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var onboarding = OnboardingFeature.State()
        var path = StackState<Path.State>()
        var search = SearchCompanyFeature.State()
        var isFirstLaunch = true
        var isBootstrapping = true
    }
    
    enum Action {
        case appLaunched
        case initKakaoSDK
        case setIsFirstLaunch
        case endBootstrap
        case onboarding(OnboardingFeature.Action)
        case path(StackActionOf<Path>)
        case search(SearchCompanyFeature.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
        Scope(state: \.search, action: \.search) {
            SearchCompanyFeature()
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
                
            case .path:
                return .none
                
            case .search:
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
        OnboardingView(
            store: store.scope(
                state: \.onboarding,
                action: \.onboarding
            )
        )
    }
    
    private var main: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            SearchCompanyView(
                store: store.scope(state: \.search, action: \.search)
            )
        } destination: { store in
            switch store.case {
            case let .detail(detailStore):
                CompanyDetailView(store: detailStore)
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
    
    var body: some Scene {
        WindowGroup {
            UpView(store: Self.store)
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
