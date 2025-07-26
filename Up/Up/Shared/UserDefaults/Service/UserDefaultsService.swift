//
//  UserDefaultsService.swift
//  Up
//
//  Created by Jun Young Lee on 7/22/25.
//

import Foundation
import Dependencies

protocol UserDefaultsService {
    func fetch<T>(key: String, type: T.Type) throws -> T? where T: Decodable
    func save<T>(key: String, value: T) throws where T: Encodable
    func remove(key: String)
    func reset()
}

private enum UserDefaultsServiceKey: DependencyKey {
    static let liveValue: any UserDefaultsService = DefaultUserDefaultsService(
        userDefaults: UserDefaults.standard,
        decoder: JSONDecoder(),
        encoder: JSONEncoder()
    )
}

extension DependencyValues {
    var userDefaultsService: any UserDefaultsService {
        get { self[UserDefaultsServiceKey.self] }
        set { self[UserDefaultsServiceKey.self] = newValue }
    }
}

protocol Decoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: Decoder {}

protocol Encoder {
    func encode<T>(_ value: T) throws -> Data where T: Encodable
}

extension JSONEncoder: Encoder {}

struct DefaultUserDefaultsService: UserDefaultsService {
    private let userDefaults: UserDefaults
    private let decoder: Decoder
    private let encoder: Encoder
    
    init(userDefaults: UserDefaults, decoder: Decoder, encoder: Encoder) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func fetch<T>(key: String, type: T.Type) throws -> T? where T : Decodable {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        return try decoder.decode(type, from: data)
    }
    
    func save<T>(key: String, value: T) throws where T : Encodable {
        let data = try encoder.encode(value)
        
        userDefaults.set(data, forKey: key)
    }
    
    func remove(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func reset() {
        let hasLaunchedBefore = try? fetch(key: "hasLaunchedBefore", type: Bool.self) // 남겨둬야 할 값
        
        if let appDomain = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: appDomain) // 일괄 삭제
        }
        
        try? save(key: "hasLaunchedBefore", value: hasLaunchedBefore) // 남겨둬야 할 값 재저장
    }
}
