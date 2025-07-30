//
//  AppFont.swift
//  Up
//
//  Created by Wonbi on 5/24/25.
//

import SwiftUI

enum AppFont: String {
    
    enum Typography {
        case pretendard
        case zenDots
        
        var fileName: String {
            switch self {
            case .pretendard:
                return "Pretendard"
            case .zenDots:
                return "ZenDots"
            }
        }
    }
    
    case h1Bold
    case h1Regular
    case h2
    case h3Bold
    case h3Regular
    case body1Bold
    case body1SemiBold
    case body1Regular
    case body2Bold
    case body2Regular
    case captionBold
    case captionRegular
    case captionSemiBold
    case logo
    case splash
    
    var weight: String {
        switch self {
        case .h1Bold, .h2, .h3Bold, .body1Bold, .body2Bold, .captionBold:
            return "Bold"
        case .h1Regular, .h3Regular, .body1Regular, .body2Regular, .captionRegular, .logo, .splash:
            return "Regular"
        case .body1SemiBold, .captionSemiBold:
            return "SemiBold"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .splash:
            return 36
        case .h1Bold, .h1Regular, .logo:
            return 22
        case .h2:
            return 20
        case .h3Bold, .h3Regular:
            return 18
        case .body1Bold, .body1SemiBold, .body1Regular:
            return 16
        case .body2Bold, .body2Regular:
            return 14
        case .captionBold, .captionRegular, .captionSemiBold:
            return 12
        }
    }
    
    private var typography: Typography {
        switch self {
        case .logo, .splash:
            return .zenDots
        default:
            return .pretendard
        }
    }
    
    private var uiFont: UIFont {
        return .init(name: "\(typography.fileName)-\(weight)", size: size) ?? .systemFont(ofSize: size)
    }
    
    var font: Font {
        return .custom("\(typography.fileName)-\(weight)", fixedSize: size)
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .h1Bold, .h2, .h3Bold, .h3Regular, .body1Bold, .body2Bold, .captionBold, .captionSemiBold, .logo, .splash:
            return (uiFont.pointSize * 0.3) / 2
        case .h1Regular, .body1Regular, .body1SemiBold, .body2Regular, .captionRegular:
            return (uiFont.pointSize * 0.5) / 2
        }
    }
}

extension View {
    func pretendard(_ font: AppFont, color: AppColor = .black) -> some View {
        self
            .font(font.font)
            .foregroundStyle(color.color)
            .padding(.vertical, font.lineSpacing / 2)
            .lineSpacing(font.lineSpacing)
    }
    
    func pretendard(_ font: AppFont, sysyemColor: Color) -> some View {
        self
            .font(font.font)
            .foregroundStyle(sysyemColor)
            .padding(.vertical, font.lineSpacing / 2)
            .lineSpacing(font.lineSpacing)
    }
}
