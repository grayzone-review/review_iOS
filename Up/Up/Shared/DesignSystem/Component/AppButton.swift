//
//  AppButton.swift
//  Up
//
//  Created by Jun Young Lee on 6/23/25.
//

import SwiftUI

struct AppButton: View {
    let icon: AppIcon?
    let style: Style
    let size: Size
    let mode: SizingMode
    let text: String
    let typography: Typography
    let action: @MainActor () -> Void
    
    /// 버튼을 라벨로 사용할 때 true로 두면, 터치로직을 비활성화합니다.
    let isLabel: Bool
    let disabled: Bool
    
    init(
        icon: AppIcon? = nil,
        style: Style,
        size: Size = .regular,
        mode: SizingMode = .fill,
        text: String,
        typography: Typography = .body1Bold,
        isEnabled: Bool = true,
        isLabel: Bool = false,
        action: @escaping () -> Void = { }
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.mode = mode
        self.text = text
        self.typography = typography
        self.disabled = !isEnabled
        self.isLabel = isLabel
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Group {
                switch mode {
                case .intrinsic:
                    textView
                case .fill:
                    HStack(spacing: 0) {
                        Spacer()
                        
                        textView
                        
                        Spacer()
                    }
                }
            }
            .frame(height: size.height)
            .padding(.horizontal, 20)
            .background {
                style.makeButtonShape(disabled: disabled)
            }
        }
        .disabled(disabled || isLabel)
    }
    
    var textView: some View {
        HStack(spacing: 6) {
            if let icon {
                icon.image
                    .frame(width: 16, height: 16)
                    .foregroundStyle(style.textColor.color)
            }
            Text(text)
                .pretendard(typography, color: style.textColor)
        }
    }
}

extension AppButton {
    enum SizingMode {
        /// 텍스트 길이+패딩 만큼만
        case intrinsic
        /// 가능한 최대 폭까지 확장
        case fill
    }
    
    enum Size {
        /// 높이 40
        case small
        /// 높이 48
        case regular
        /// 높이 52
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
    
    enum Style {
        /// 배경색이 있는 버튼
        case fill
        /// 테두리만 있는 버튼
        case stroke
        /// 테두리와 배경색이 있는 버튼
        case strokeFill
        
        var borderColor: Color {
            switch self {
            case .fill:
                return .clear
            case .stroke, .strokeFill:
                return AppColor.orange40.color
            }
        }
        
        var fillColor: Color {
            switch self {
            case .fill:
                return AppColor.orange40.color
            case .stroke:
                return .white
            case .strokeFill:
                return AppColor.orange10.color
            }
        }
        
        var textColor: AppColor {
            switch self {
            case .fill:
                return AppColor.white
            case .stroke, .strokeFill:
                return AppColor.orange40
            }
        }
        
        @ViewBuilder
        func makeButtonShape(disabled: Bool) -> some View {
            switch self {
            case .fill:
                RoundedRectangle(cornerRadius: 8)
                    .fill(disabled ? AppColor.orange20.color : self.fillColor)
            case .stroke, .strokeFill:
                RoundedRectangle(cornerRadius: 8)
                    .fill(self.fillColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(self.borderColor, lineWidth: 1)
                    }
            }
        }
    }
}

#Preview {
    VStack {
        HStack(spacing: 12) {
            AppButton(
                icon: .followLine,
                style: .fill,
                text: "팔로우"
            ) { }
            AppButton(
                icon: .penFill,
                style: .stroke,
                text: "리뷰 작성"
            ) { }
        }
        .padding(.horizontal, 16)
        
        HStack(alignment: .top) {
            VStack {
                AppButton(
                    icon: .appleFill,
                    style: .stroke,
                    size: .small,
                    mode: .intrinsic,
                    text: "작은 버튼",
                    action: { }
                )
                AppButton(
                    icon: .appleFill,
                    style: .fill,
                    size: .small,
                    mode: .intrinsic,
                    text: "작은 버튼",
                    action: { }
                )
                AppButton(
                    icon: .appleFill,
                    style: .fill,
                    size: .small,
                    mode: .intrinsic,
                    text: "작은 버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    icon: .appleFill,
                    style: .strokeFill,
                    size: .small,
                    mode: .intrinsic,
                    text: "작은 버튼",
                    action: { }
                )
            }
            VStack {
                AppButton(
                    icon: .followLine,
                    style: .stroke,
                    size: .regular,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    icon: .followLine,
                    style: .fill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    icon: .followLine,
                    style: .fill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    icon: .followLine,
                    style: .strokeFill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
            }
            VStack {
                AppButton(
                    icon: .heartLine,
                    style: .stroke,
                    size: .large,
                    mode: .intrinsic,
                    text: "안눌리는 버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    icon: .heartLine,
                    style: .fill,
                    size: .large,
                    mode: .intrinsic,
                    text: "잘눌리는 버튼",
                    action: { }
                )
                AppButton(
                    icon: .heartLine,
                    style: .fill,
                    size: .large,
                    mode: .intrinsic,
                    text: "안눌리는 버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    icon: .heartLine,
                    style: .strokeFill,
                    size: .large,
                    mode: .intrinsic,
                    text: "안눌리는 버튼",
                    isEnabled: false,
                    action: { }
                )
            }
        }
        
        HStack(alignment: .top) {
            VStack {
                AppButton(
                    style: .stroke,
                    size: .small,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .small,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .small,
                    mode: .intrinsic,
                    text: "버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    style: .strokeFill,
                    size: .small,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
            }
            VStack {
                AppButton(
                    style: .stroke,
                    size: .regular,
                    mode: .intrinsic,
                    text: "꽤나 긴 이름의 버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "꽤나 긴 이름의 버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "꽤나 긴 이름의 버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    style: .strokeFill,
                    size: .regular,
                    mode: .intrinsic,
                    text: "꽤나 긴 이름의 버튼",
                    action: { }
                )
            }
            VStack {
                AppButton(
                    style: .stroke,
                    size: .large,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .large,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .large,
                    mode: .intrinsic,
                    text: "버튼",
                    isEnabled: false,
                    action: { }
                )
                AppButton(
                    style: .strokeFill,
                    size: .large,
                    mode: .intrinsic,
                    text: "버튼",
                    action: { }
                )
            }
        }
        
        
        VStack {
            HStack(spacing: 10) {
                AppButton(
                    style: .stroke,
                    size: .large,
                    text: "이전",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .large,
                    text: "다음",
                    action: { }
                )
            }
            .padding(.horizontal, 16)
            
            HStack(spacing: 10) {
                AppButton(
                    style: .stroke,
                    size: .large,
                    text: "이전",
                    action: { }
                )
                AppButton(
                    style: .fill,
                    size: .large,
                    text: "다음",
                    isEnabled: false,
                    action: { }
                )
            }
            .padding(.horizontal, 16)
            
            
            AppButton(
                style: .fill,
                size: .large,
                text: "다음",
                isEnabled: false,
                action: { }
            )
            .padding(.horizontal, 16)
            
            AppButton(
                style: .fill,
                size: .large,
                text: "다음",
                action: { }
            )
            .padding(.horizontal, 16)
            
        }
    }
}
