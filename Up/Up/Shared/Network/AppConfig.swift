//
//  AppConfig.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

enum AppConfig {
    enum Network {
        #if DEBUG
        static let host: String = "https://localhost:8080"
        #else
        static let host: String = "실서버 호스트 URL"
        #endif
    }
}
