//
//  GrayzoneApp.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoMapsSDK

@main
struct GrayzoneApp: App {
    
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
    }
}
