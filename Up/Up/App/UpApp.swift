//
//  UpApp.swift
//  UpApp
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI
import SwiftData
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
        var path = StackState<Path.State>()
        var search = SearchCompanyFeature.State()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case search(SearchCompanyFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.search, action: \.search) {
            SearchCompanyFeature()
        }
        Reduce { state, action in
            switch action {
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
    static let store = Store(
        initialState: UpFeature.State()
    ) {
        UpFeature()
    }
    
    var modelContainer: ModelContainer = {
        let schema = Schema([RecentSearchTerm.self])
        let configuration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer 생성 실패: \(error)")
        }
    }()
    
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
                .modelContainer(modelContainer)
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
