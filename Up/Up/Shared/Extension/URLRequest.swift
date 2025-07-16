//
//  URLRequest.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

import Foundation

extension URLRequest {
    /// Encodable 모델을 JSON으로 인코딩해 바디와 Content-Type 헤더를 설정합니다.
    mutating func setJSONBody<T: Encodable>(_ encodable: T) throws {
        self.httpBody = try JSONEncoder().encode(encodable)
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
