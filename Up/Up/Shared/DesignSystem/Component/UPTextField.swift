//
//  UPTextField.swift
//  Up
//
//  Created by Jun Young Lee on 6/23/25.
//

import SwiftUI

struct UPTextField: View {
    let style: Style
    let placeholder: String
    let leftComponent: LeftComponent
    let rightComponent: RightComponent
    let onFocusedChange: ((Bool, Bool) -> Void)?
    let onTextChange: (String, String) -> Void
    
    @FocusState private var focused: Bool
    @Binding var text: String
    @Binding var isFocused: Bool
    
    init(
        style: Style = .border,
        text: Binding<String>,
        isFocused: Binding<Bool>,
        placeholder: String,
        leftComponent: LeftComponent = .none,
        rightComponent: RightComponent = .none,
        onFocusedChange: ((Bool, Bool) -> Void)? = nil,
        onTextChange: @escaping (String, String) -> Void
    ) {
        self.style = style
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.leftComponent = leftComponent
        self.rightComponent = rightComponent
        self.onFocusedChange = onFocusedChange
        self.onTextChange = onTextChange
    }
    
    var body: some View {
        HStack(spacing: 8) {
            leftComponent.view
            
            textField
            
            rightButton
        }
        .padding(16)
        .frame(height: 52)
        .background {
            switch style {
            case .border:
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        focused ? AppColor.gray90.color : AppColor.gray20.color,
                        lineWidth: 1
                    )
            case .fill:
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.gray10.color)
            }
            
        }
    }
    
    private var textField: some View {
        TextField(
            placeholder,
            text: $text
        )
        .focused($focused)
        .bind($isFocused, to: $focused)
        .lineLimit(1)
        .pretendard(.body1Regular, color: .gray90)
        .onChange(of: focused, onFocusedChange ?? { _, _ in })
        .onChange(of: text, onTextChange)
    }
    
    @ViewBuilder
    var rightButton: some View {
        switch rightComponent {
        case .none:
            EmptyView()
        case let .clear(action):
            if focused, !text.isEmpty {
                Button {
                    text = ""
                    action?()
                } label: {
                    AppIcon.closeCircleFillGray24.image(width: 24, height: 24)
                }
            }
        }
    }
}

extension UPTextField {
    enum Style {
        case border
        case fill
    }
    
    enum LeftComponent {
        case none
        case icon(
            appIcon: AppIcon,
            size: CGFloat,
            color: AppColor? = nil
        )
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .none:
                EmptyView()
            case let .icon(appIcon, size, color):
                icon(appIcon: appIcon, size: size, color: color)
            }
        }
        
        @ViewBuilder
        private func icon(appIcon: AppIcon, size: CGFloat, color: AppColor?) -> some View {
            if let color {
                appIcon.image(width: size, height: size, appColor: color)
            } else {
                appIcon.image(width: size, height: size)
            }
        }
    }
    
    enum RightComponent {
        case none
        case clear((() -> Void)? = nil)
    }
    
}

#Preview {
    VStack {
        UPTextField(
            text: .constant(""),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            text: .constant(""),
            isFocused: .constant(true),
            placeholder: "상호명으로 검색하기",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            text: .constant("스타벅스 석촌역점"),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        
        UPTextField(
            text: .constant(""),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            leftComponent: .icon(appIcon: .searchLine, size: 24, color: .gray90),
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            text: .constant(""),
            isFocused: .constant(true),
            placeholder: "상호명으로 검색하기",
            leftComponent: .icon(appIcon: .searchLine, size: 24, color: .gray90),
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            text: .constant("스타벅스 석촌역점"),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            leftComponent: .icon(appIcon: .searchLine, size: 24, color: .gray90),
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        
        UPTextField(
            style: .fill,
            text: .constant(""),
            isFocused: .constant(false),
            placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            style: .fill,
            text: .constant(""),
            isFocused: .constant(true),
            placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
        UPTextField(
            style: .fill,
            text: .constant("스타벅스 석촌역점스타벅스 석촌역점스타벅스 석촌역점스타벅스 석촌역점"),
            isFocused: .constant(false),
            placeholder: "동명 (읍, 면)으로 검색 (ex. 서초동)",
            rightComponent: .clear(),
            onTextChange: { _,_ in }
        )
    }
    .padding()
}
