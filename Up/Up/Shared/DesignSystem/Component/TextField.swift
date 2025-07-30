//
//  TextField.swift
//  Up
//
//  Created by Wonbi on 6/24/25.
//

import SwiftUI

struct DupCheckTextField: View {
    static private let allowedCharacterSet = {
        let syllables = CharacterSet(charactersIn: "\u{AC00}"..."\u{D7AF}")       // 한글 완성형
        let jamo      = CharacterSet(charactersIn: "\u{3131}"..."\u{318E}")       // 호환 자모 (자음·모음)
        let english   = CharacterSet(charactersIn: "A"..."Z")
                        .union(CharacterSet(charactersIn: "a"..."z"))
        let digits    = CharacterSet.decimalDigits

        return syllables
            .union(jamo)
            .union(english)
            .union(digits)
    }()
    
    enum FieldState: Equatable {
        case `default`
        case focused
        case invalid
        case valid
        
        var textColor: AppColor {
            if self == .invalid {
                return .red
            } else {
                return .gray90
            }
        }
        
        var strokeColor: AppColor {
            switch self {
            case .default, .valid:
                return .gray20
            case .invalid:
                return .red
            case .focused:
                return .gray90
            }
        }
        
        var notiColor: AppColor {
            switch self {
            case .default, .focused:
                return .gray50
            case .invalid:
                return .red
            case .valid:
                return .blue
            }
        }
    }
    
    var isFocused: FocusState<Bool>.Binding
    
    @State private var isCheckable: Bool = false
    
    @Binding var state: FieldState
    @Binding var text: String
    @Binding var noti: String
    
    let initialText: String
    let defaultNoti: String = "2~12자 이내로 입력가능하며, 한글, 영문, 숫자 사용이 가능합니다."
    let placeholder: String
    let checkDupTapped: () -> Void
    
    init(
        text: Binding<String>,
        state: Binding<FieldState>,
        isFocused: FocusState<Bool>.Binding,
        noti: Binding<String>,
        initialText: String = "",
        placeholder: String,
        checkDupTapped: @escaping () -> Void
    ) {
        self._text = text
        self._state = state
        self._noti = noti
        self.initialText = initialText
        self.isFocused = isFocused
        self.placeholder = placeholder
        self.checkDupTapped = checkDupTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                textField
                
                verifyButton
            }
            .padding(16)
            .frame(height: 52)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(state.strokeColor.color)
            }
            .onSubmit {
                isFocused.wrappedValue = false
            }
            
            Text("※ \(noti)")
                .pretendard(.captionRegular, color: state.notiColor)
        }
        .onChange(of: isFocused.wrappedValue) { old, new in
            guard state != .valid else { return }
            state = new ? .focused : .default
        }
        .onChange(of: text) { old, new in
            // 중복 체크 성공 후, 다시 내용을 수정한 경우
            if state == .valid, old != new {
                state = isFocused.wrappedValue ? .focused : .default
                noti = defaultNoti
                return
            }
            
            // 입력값이 비었거나 initialText와 일치할 때
            if new.isEmpty || initialText == new {
                state = isFocused.wrappedValue ? .focused : .default
                noti = defaultNoti
                isCheckable = false
                return
            }
            
            // 일반적인 입력 상황
            let text = getValidText(new)
            let isVaild = (2...12).contains(text.count) && !text.isEmpty
            
            state = isVaild ? (isFocused.wrappedValue ? .focused : .default) : .invalid
            self.isCheckable = isVaild
            self.text = text
        }
    }
    
    var textField: some View {
        TextField(
            placeholder,
            text: $text
        )
        .focused(isFocused)
        .lineLimit(1)
        .pretendard(.body1Regular, color: state.textColor)
    }
    
    var verifyButton: some View {
        Button {
            checkDupTapped()
        } label: {
            Text("중복 확인")
                .pretendard(.body2Regular, color: .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 5.5)
                .background {
                    Capsule()
                        .fill(isCheckable ? AppColor.orange40.color : AppColor.orange20.color)
                }
        }
        .disabled(!isCheckable)
    }
    
    private func getValidText(_ input: String) -> String {
        let filtered = input.unicodeScalars
            .filter { Self.allowedCharacterSet.contains($0) }
        var sanitized = String(String.UnicodeScalarView(filtered))
        
        if sanitized.count > 12 {
            sanitized = String(sanitized.prefix(12))
        }
        
        return sanitized
    }
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @FocusState var isFocused: Bool
    
    DupCheckTextField(text: $text, state: .constant(.default), isFocused: $isFocused, noti: .constant("asdkwdaoowrf"), placeholder: ":qwe") { }
}
