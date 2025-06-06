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

@main
struct UpApp: App {
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
            NavigationStack {
                CompanyDetailView(
                    store: Store(
                        initialState: CompanyDetailFeature.State(
                            companyID: 1,
                            reviews: Shared(value: [])
                        )
                    ) {
                        CompanyDetailFeature()
                    }
                )
            }
        }
        .modelContainer(modelContainer)
    }
}
