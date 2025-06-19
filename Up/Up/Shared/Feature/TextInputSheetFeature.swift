//
//  TextInputSheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct TextInputSheetFeature {
    typealias Validator = (_ oldValue: String, _ newValue: String) -> String
    
    @ObservableState
    struct State: Equatable {
        let title: String
        let placeholder: String
        let minimum: Int
        let maximum: Int
        var text: String
        
        var isSaveButtonEnabled: Bool {
            minimum...maximum ~= text.count
        }
        
        var textCount: AttributedString {
            var attributedString = AttributedString("\(text.count)/\(minimum)자 - \(maximum)자")
            
            attributedString.foregroundColor = AppColor.gray50.color
            attributedString.font = Typography.captionRegular.font
            
            switch text.count {
            case ..<minimum:
                break
            case ...maximum:
                if let range = attributedString.range(of: "\(text.count)") {
                    attributedString[range].foregroundColor = AppColor.orange40.color
                }
            default:
                if let range = attributedString.range(of: "\(text.count)") {
                    attributedString[range].foregroundColor = AppColor.red.color
                }
            }
            
            return attributedString
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case textChanged(oldValue: String, newValue: String)
        case saveButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case save(String)
        }
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.validator) var validator
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .textChanged(oldValue, newValue):
                state.text = validator(oldValue, newValue)
                return .none
                
            case .saveButtonTapped:
                guard state.isSaveButtonEnabled else {
                    return .none
                }
                
                return .run { [text = state.text] send in
                    await send(.delegate(.save(text)))
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

private enum TextInputSheetValidatorKey: DependencyKey {
    static var liveValue: TextInputSheetFeature.Validator = { oldValue, newValue in
        var result = newValue
        
        for (asIs, toBe) in [("   ", "  "), ("\n\n", "\n"), ("\n \n", "\n "), ("\n  \n", "\n  ")] {
            while result.contains(asIs) {
                result = result.replacingOccurrences(of: asIs, with: toBe)
            }
        }
        
        return result.filter { $0.isEmoji == false }
    }
}

extension DependencyValues {
    var validator: TextInputSheetFeature.Validator {
        get { self[TextInputSheetValidatorKey.self] }
        set { self[TextInputSheetValidatorKey.self] = newValue }
    }
}

struct TextInputSheetView: View {
    @Bindable var store: StoreOf<TextInputSheetFeature>
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            title
            textField
            controlArea
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private var title: some View {
        HStack {
            Spacer()
            Text(store.title)
                .pretendard(.body1Bold, color: .gray90)
            Spacer()
        }
        .padding(
            EdgeInsets(
                top: 8,
                leading: 20,
                bottom: 8,
                trailing: 20
            )
        )
    }
    
    private var textField: some View {
        VStack(spacing: 0) {
            TextField(
                store.placeholder,
                text: $store.text,
                axis: .vertical,
            )
            .focused($isFocused)
            .lineLimit(.max)
            .onChange(of: store.text) { oldValue, newValue in
                store.send(.textChanged(oldValue: oldValue, newValue: newValue))
            }
            Spacer()
        }
        .padding(20)
    }
    
    private var controlArea: some View {
        HStack {
            Text(store.textCount)
            Spacer()
            Button {
                store.send(.saveButtonTapped)
            } label: {
                Text("저장")
                    .pretendard(.body1Bold, color: store.isSaveButtonEnabled ? .orange40 : .orange20)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(20)
    }
}

#Preview {
    TextInputSheetView(
        store: Store(
            initialState: TextInputSheetFeature.State(
                title: "업무 내용",
                placeholder: "담당하신 역할을 입력해주세요 ex) 서빙",
                minimum: 2,
                maximum: 10,
                text: ""
            )
        ) {
            TextInputSheetFeature()
        }
    )
}
