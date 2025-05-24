//
//  AppColor.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/24/25.
//

import SwiftUI

fileprivate extension Color {
    /// 16진수 문자열로부터 Color 생성
    /// - Parameter hex: "#RRGGBB", "RRGGBB", "#RRGGBBAA" 또는 "RRGGBBAA" 형태의 문자열
    init(hex: String) {
        // 1. 문자열 전처리 (#, 공백 제거, 대문자 변환)
        var hexStr = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        if hexStr.hasPrefix("#") {
            hexStr.removeFirst()
        }

        // 3. 스캐너로 UInt64 변환
        var hexValue: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&hexValue)

        // 4. R, G, B, A 분리
        let hasAlpha = (hexStr.count == 8)
        let divisor = Double(255)
        let red:   Double
        let green: Double
        let blue:  Double
        let alpha: Double

        if hasAlpha {
            red   = Double((hexValue & 0xFF000000) >> 24) / divisor
            green = Double((hexValue & 0x00FF0000) >> 16) / divisor
            blue  = Double((hexValue & 0x0000FF00) >> 8 ) / divisor
            alpha = Double( hexValue & 0x000000FF       ) / divisor
        } else {
            red   = Double((hexValue & 0xFF0000) >> 16) / divisor
            green = Double((hexValue & 0x00FF00) >> 8 ) / divisor
            blue  = Double( hexValue & 0x0000FF       ) / divisor
            alpha = 1.0
        }

        // 5. Color 초기화
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

enum AppColor: String {
    // Primary color
    case orange10 = "#FFF5F2"
    case orange20 = "#FFBBA6"
    case orange30 = "#FF9573"
    case orange40 = "#FF6E40"
    case orange50 = "#FF5B26"
    case orange60 = "#FF470D"
    case orange70 = "#D93400"
    
    // Second color
    case blue10 = "#EFF1FF"
    case blue20 = "#A2B0FF"
    case blue30 = "#7085FE"
    case blue40 = "#3D5AFE"
    case blue50 = "#2444FE"
    case blue60 = "#0A2FFE"
    case blue70 = "#0121D4"
    
    // Semantic color-red
    case seRed10 = "#FFF2F2"
    case seRed20 = "#FFA6A6"
    case seRed30 = "#FF7373"
    case seRed40 = "#FF4040"
    case seRed50 = "#FF0D0D"
    case seRed60 = "#D90000"
    case seRed70 = "#A60000"
    
    // Semantic color-blue
    case seBlue10 = "#F2F8FF"
    case seBlue20 = "#A6CFFF"
    case seBlue30 = "#73B4FF"
    case seBlue40 = "#4099FF"
    case seBlue50 = "#0D7EFF"
    case seBlue60 = "#0065D9"
    case seBlue70 = "#004DA6"
    
    // Semantic color-yellow
    case seYellow10 = "#FFFBF2"
    case seYellow20 = "#FFE3A6"
    case seYellow30 = "#FFD373"
    case seYellow40 = "#FFC340"
    case seYellow50 = "#FFB30D"
    case seYellow60 = "#D99500"
    case seYellow70 = "#A67200"
    
    // System color
    case red    = "#D92727"
    case yellow = "#FCC425"
    case blue   = "#2786D9"
    
    // Gray scale
    case white  = "#FFFFFF"
    case gray10 = "#F5F5F5"
    case gray20 = "#E0E0E0"
    case gray30 = "#BDBDBD"
    case gray40 = "#9E9E9E"
    case gray50 = "#757575"
    case gray60 = "#616161"
    case gray70 = "#424242"
    case gray80 = "#212121"
    case gray90 = "#141414"
    case black  = "#000000"
    
    var color: Color {
        return Color(hex: rawValue)
    }
}

extension Color {
    static func appColor(_ color: AppColor) -> Color {
        color.color
    }
}
