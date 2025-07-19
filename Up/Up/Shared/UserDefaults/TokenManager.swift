//
//  TokenManager.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Foundation
import Security
import Dependencies

/// JWT 액세스 토큰 및 리프레시 토큰을 UserDefaults에 저장/조회하는 싱글톤 매니저
/// - 로그인 시 토큰을 저장하고, 로그아웃 시 clearTokens()를 호출해 값을 제거
actor TokenManager {
    static let shared = TokenManager()

    private enum Keys {
        static let accessToken = "JWT_AccessToken"
        static let refreshToken = "JWT_RefreshToken"
    }

    private init() {}
    
    @Dependency(\.userDefaultsService) var userDefaultsService

    /// 현재 저장된 액세스 토큰 (Bearer 토큰)
    private var accessToken: String? {
        get {
            try? userDefaultsService.fetch(key: Keys.accessToken, type: String.self)
        }
        set {
            if let new = newValue {
                try? userDefaultsService.save(key: Keys.accessToken, value: new)
            } else {
                userDefaultsService.remove(key: Keys.accessToken)
            }
        }
    }

    /// 현재 저장된 리프레시 토큰
    private var refreshToken: String? {
        get {
            try? userDefaultsService.fetch(key: Keys.refreshToken, type: String.self)
        }
        set {
            if let new = newValue {
                try? userDefaultsService.save(key: Keys.refreshToken, value: new)
            } else {
                userDefaultsService.remove(key: Keys.refreshToken)
            }
        }
    }

    /// 현재 액세스 토큰 가져오기
    func getAccessToken() -> String? {
        return accessToken
    }

    /// 새로운 액세스 토큰 저장하기
    func setAccessToken(_ token: String?) {
        accessToken = token
    }

    /// 현재 리프레시 토큰 가져오기
    func getRefreshToken() -> String? {
        return refreshToken
    }

    /// 새로운 리프레시 토큰 저장하기
    func setRefreshToken(_ token: String?) {
        refreshToken = token
    }
    
    /// 액세스 토큰이 있는지 여부 (nil이 아니면 true)
    var hasValidAccessToken: Bool {
        return accessToken != nil
    }

    /// 액세스 토큰과 리프레시 토큰을 모두 삭제 (로그아웃 시 사용)
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}

actor SecureTokenManager {
    static let shared = SecureTokenManager()
    private init() {}

    private enum KeychainKey {
        static let access = "com.up.jwt.access"
        static let refresh = "com.up.jwt.refresh"
    }

    // MARK: - Public API

    func getAccessToken() -> String? {
        return retrieve(key: KeychainKey.access)
    }

    func setAccessToken(_ token: String?) {
        store(token: token, key: KeychainKey.access)
    }

    func getRefreshToken() -> String? {
        return retrieve(key: KeychainKey.refresh)
    }

    func setRefreshToken(_ token: String?) {
        store(token: token, key: KeychainKey.refresh)
    }

    func clearTokens() {
        delete(key: KeychainKey.access)
        delete(key: KeychainKey.refresh)
    }

    // MARK: - Keychain Helpers

    private func store(token: String?, key: String) {
        let data = token?.data(using: .utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecValueData: data as Any,
            // 디바이스에 잠금 해제 후 접근 가능
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // 이미 있으면 업데이트, 없으면 추가
        if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
            let update: [CFString: Any] = [kSecValueData: data as Any]
            SecItemUpdate(query as CFDictionary, update as CFDictionary)
        } else {
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    private func retrieve(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else { return nil }
        return token
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
