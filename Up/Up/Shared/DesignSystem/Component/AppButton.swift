//
//  AppButton.swift
//  Up
//
//  Created by Jun Young Lee on 6/23/25.
//

import SwiftUI

struct AppButton: View {
    let icon: AppIcon?
    let text: String
    let size: Size
    let isFilled: Bool
    let isEnabled: Bool
    let action: @MainActor () -> Void
    
    init(
        icon: AppIcon? = nil,
        text: String,
        size: Size = .regular,
        isFilled: Bool = true,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.size = size
        self.isFilled = isFilled
        self.isEnabled = isEnabled
        self.action = action
    }
    
    private var accentColor: AppColor {
        isEnabled ? .orange40 : .orange20
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    icon.image
                        .frame(width: 16, height: 16)
                }
                Text(text)
            }
            .pretendard(.body1Bold, color: isFilled ? .white : accentColor)
            .frame(height: size.height)
            .frame(maxWidth: .infinity)
            .background(isFilled ? accentColor.color : nil)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFilled ? .clear : accentColor.color)
            )
        }
    }
}

extension AppButton {
    enum Size {
        case small
        case regular
        case large
        
        var height: CGFloat {
            switch self {
            case .small:
                40
            case .regular:
                48
            case .large:
                52
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        AppButton(
            icon: .followLine,
            text: "팔로우",
            isFilled: false,
            action: {}
        )
        AppButton(
            icon: .penFill,
            text: "리뷰 작성",
            action: {}
        )
    }
}
