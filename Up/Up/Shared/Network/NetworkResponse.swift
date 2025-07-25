//
//  NetworkResponse.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

/// 런타임에 임의의 키 이름을 받을 수 있는 CodingKey 구현체
struct AnyCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
}

/// data가 null이거나 빈 객체({})로 내려와도 에러 없이 통과시키는 빈 타입
struct NilResponse: Codable {
    init() {}
    
    init(from decoder: Swift.Decoder) throws {
        let container = try decoder.singleValueContainer()
        // JSON이 null이면 decodeNil()이 true가 되고,
        // {}같은 빈 객체가 내려오면 컨테이너 자체가 비어있으므로 통과
        if container.decodeNil() {
            // null인 경우 아무것도 할 것 없이 리턴
            return
        }
        // 혹시 빈 객체({})가 내려오는 경우, container를 키드 컨테이너로 열어보기
        if let keyed = try? decoder.container(keyedBy: AnyCodingKey.self) {
            // 빈 딕셔너리면 키가 없으니 통과
            guard !keyed.allKeys.isEmpty else { return }
        }
    }
}

struct NetworkResponse<T: Codable>: Codable {
    let data: T
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case success
        case message
    }
}

struct FailResponse: Error, Codable, Equatable {
    let code: Int
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case success
        case message
    }
}
