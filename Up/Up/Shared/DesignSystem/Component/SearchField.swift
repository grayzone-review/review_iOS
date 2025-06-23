//
//  SearchField.swift
//  Up
//
//  Created by Jun Young Lee on 6/23/25.
//

import SwiftUI

struct SearchField: View {
    @Binding var text: String
    @FocusState private var focused: Bool
    @Binding var isFocused: Bool
    let placeholder: String
    let onFocusedChange: ((Bool, Bool) -> Void)?
    let onTextChange: (String, String) -> Void
    let onClearButtonTapped: (() -> Void)?
    
    init(
        text: Binding<String>,
        isFocused: Binding<Bool>,
        placeholder: String,
        onFocusedChange: ((Bool, Bool) -> Void)? = nil,
        onTextChange: @escaping (String, String) -> Void,
        onClearButtonTapped: (() -> Void)? = nil
    ) {
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.onFocusedChange = onFocusedChange
        self.onTextChange = onTextChange
        self.onClearButtonTapped = onClearButtonTapped
    }
    
    var body: some View {
        HStack(spacing: 8) {
            searchIcon
            textField
            clearButton
        }
        .padding(16)
        .frame(height: 52)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(focused ? AppColor.gray90.color : AppColor.gray20.color)
        }
    }
    
    private var searchIcon: some View {
        AppIcon.searchLine.image(
            width: 24,
            height: 24,
            appColor: .gray90
        )
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
    private var clearButton: some View {
        if focused || text.isEmpty == false {
            Button {
                text = ""
                onClearButtonTapped?()
            } label: {
                AppIcon.closeCircleFill.image(
                    width: 24,
                    height: 24,
                    appColor: .gray10
                )
                .overlay {
                    AppIcon.closeLine.image(
                        width: 16,
                        height: 16,
                        appColor: .gray50
                    )
                }
            }
        }
    }
}

#Preview {
    VStack {
        SearchField(
            text: .constant(""),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            onTextChange: { _,_ in }
        )
        SearchField(
            text: .constant(""),
            isFocused: .constant(true),
            placeholder: "상호명으로 검색하기",
            onTextChange: { _,_ in }
        )
        SearchField(
            text: .constant("스타벅스 석촌역점"),
            isFocused: .constant(false),
            placeholder: "상호명으로 검색하기",
            onTextChange: { _,_ in }
        )
    }
    .padding()
}
