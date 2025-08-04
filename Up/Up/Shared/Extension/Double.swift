//
//  Double.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

extension Double {
    // 소수점 아래 `decimalPlaces` 자리 아래는 반올림하는 메서드
    func rounded(to decimalPlaces: Int) -> Double {
        guard decimalPlaces >= 0 else {
            return self
        }
        
        let scale = Array(repeating: 10.0, count: decimalPlaces).reduce(1, *)
        
        return (self * scale).rounded() / scale
    }
}
