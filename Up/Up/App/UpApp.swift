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
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var main = MainFeature.State()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case main(MainFeature.Action)
    }
    
    @Reducer
    enum Path {
        case activity(MyActivityFeature)
        case homeReview(HomeReviewFeature)
        case search(SearchCompanyFeature)
        case detail(CompanyDetailFeature)
        case report(ReportFeature)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
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
    
    var body: some View {
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
