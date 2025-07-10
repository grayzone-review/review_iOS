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
        
        init() {
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            
            isFirstLaunch = hasLaunchedBefore != true
        }
    }
    
    enum Action {
        case onboarding(OnboardingFeature.Action)
        case path(StackActionOf<Path>)
        case search(SearchCompanyFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        
        Scope(state: \.search, action: \.search) {
            SearchCompanyFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onboarding(.delegate(.startButtonTapped)):
                UserDefaults.standard.setValue(true, forKey: "hasLaunchedBefore")
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
    
    var body: some View {
        if store.isFirstLaunch {
            OnboardingView(
                store: store.scope(state: \.onboarding, action: \.onboarding)
            )
        } else {
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
}

@main
struct UpApp: App {
    @MainActor
    static let store = Store(
        initialState: UpFeature.State()
    ) {
        UpFeature()
    }
    
    init() {
        guard
            let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String
        else {
          fatalError("Info.plist에서 Key 정보를 읽어오지 못했습니다.")
        }
        
        SDKInitializer.InitSDK(appKey: kakaoAppKey)
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
