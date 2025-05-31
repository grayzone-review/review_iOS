//
//  AppFont.swift
//  Grayzone
//
//  Created by Wonbi on 5/24/25.
//

import SwiftUI

enum Typography: String {
    case h1
    case h2
    case h3
    case body1Bold
    case body1Regular
    case body2Bold
    case body2Regular
    case captionBold
    case captionRegular
    case captionSemiBold
    
    var weight: String {
        switch self {
        case .h1, .h2, .h3, .body1Bold, .body2Bold, .captionBold:
            return "Bold"
        case .body1Regular, .body2Regular, .captionRegular:
            return "Regular"
        case .captionSemiBold:
            return "SemiBold"
        }
    }
    
    var size: CGFloat {
        switch self {
        case .h1:
            return 22
        case .h2:
            return 20
        case .h3:
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
        return .init(name: "Pretendard-\(weight)", size: size) ?? .systemFont(ofSize: size)
    }
    
    var font: Font {
        return .custom("Pretendard-\(weight)", fixedSize: size)
    }
    
    var lineSpacing: CGFloat {
        switch self {
        case .h1, .h2, .h3, .body1Bold, .body2Bold, .captionBold, .captionSemiBold:
            return (uiFont.pointSize * 0.3) / 2
        case .body1Regular, .body2Regular, .captionRegular:
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
