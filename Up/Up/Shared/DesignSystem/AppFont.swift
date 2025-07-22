//
//  AppFont.swift
//  Up
//
//  Created by Wonbi on 5/24/25.
//

import SwiftUI

enum Typography: String {
    case h1Bold
    case h1Regular
    case h2
    case h3Bold
    case h3Regular
    case body1Bold
    case body1Regular
    case body2Bold
    case body2Regular
    case captionBold
    case captionRegular
    case captionSemiBold
    case logo
    
    var weight: String {
        switch self {
        case .h1Bold, .h2, .h3Bold, .body1Bold, .body2Bold, .captionBold:
            return "Bold"
        case .h1Regular, .h3Regular, .body1Regular, .body2Regular, .captionRegular, .logo:
            return "Regular"
        case .captionSemiBold:
            return "SemiBold"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .h1Bold, .h1Regular, .logo:
            return 22
        case .h2:
            return 20
        case .h3Bold, .h3Regular:
            return 18
        case .body1Bold, .body1Regular:
            return 16
        case .body2Bold, .body2Regular:
            return 14
        case .captionBold, .captionRegular, .captionSemiBold:
            return 12
        }
    }
    
    private var uiFont: UIFont {
        if self == .logo {
            return .init(name: "ZenDots-Regular", size: size) ?? .systemFont(ofSize: size)
        }
        return .init(name: "Pretendard-\(weight)", size: size) ?? .systemFont(ofSize: size)
    }
    
    var font: Font {
        if self == .logo {
            return .custom("ZenDots-Regular", fixedSize: size)
        }
        return .custom("Pretendard-\(weight)", fixedSize: size)
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .h1Bold, .h2, .h3Bold, .h3Regular, .body1Bold, .body2Bold, .captionBold, .captionSemiBold, .logo:
            return (uiFont.pointSize * 0.3) / 2
        case .h1Regular, .body1Regular, .body2Regular, .captionRegular:
            return (uiFont.pointSize * 0.5) / 2
        }
    }
}

extension View {
    func pretendard(_ typography: Typography, color: AppColor = .black) -> some View {
        self
            .font(typography.font)
            .foregroundStyle(color.color)
            .padding(.vertical, typography.lineSpacing / 2)
            .lineSpacing(typography.lineSpacing)
    }
}
