//
//  TokenManager.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Foundation
import Security
import Dependencies

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
