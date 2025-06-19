//
//  TextInputSheetFeature.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

import ComposableArchitecture

@Reducer
struct TextInputSheetFeature {
    typealias Validator = (_ oldValue: String, _ newValue: String) -> String
    
    @ObservableState
    struct State {
        let title: String
        let placeholder: String
        let minimum: Int
        let maximum: Int
        let textChanged: Validator
        var text: String
        
        var isSaveButtonEnabled: Bool {
            minimum...maximum ~= text.count
        }
    }
    
    enum Action {
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
        Reduce { state, action in
            switch action {
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
