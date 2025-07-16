//
//  Color.swift
//  Up
//
//  Created by Wonbi on 7/2/25.
//

import SwiftUI

extension Color {
    private init(hex: UInt, alpha: Double = 1) {
        let red   = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8)  / 255.0
        let blue  = Double(hex & 0x0000FF)         / 255.0
        let a     = alpha
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: a)
    }
    
    static func hex(_ hexString: String) -> Color {
        // 1) "#" 제거, 대소문자 무시
        var str = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        str = str.uppercased()
        
        // 2) RRGGBB(6) or AARRGGBB(8) 판별
        let hexVal = UInt(str, radix: 16) ?? 0
        switch str.count {
        case 6:
            return self.init(hex: hexVal)
        case 8:
            // 상위 2자리만 alpha로
            let alpha = Double((hexVal & 0xFF000000) >> 24) / 255.0
            let rgb   = hexVal & 0x00FFFFFF
            return self.init(hex: rgb, alpha: alpha)
        default:
            // 형식 오류 시 기본 검정
            return self.init(.black)
        }
    }
}
