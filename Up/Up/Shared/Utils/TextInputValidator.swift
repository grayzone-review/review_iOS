//
//  TextInputValidator.swift
//  Up
//
//  Created by Jun Young Lee on 8/1/25.
//

import Dependencies

typealias TextValidator = (_ oldValue: String, _ newValue: String) -> String

private enum CommentInputValidatorKey: DependencyKey {
    static var liveValue: TextValidator = { oldValue, newValue in
        var result = newValue
        
        for (asIs, toBe) in [("  ", " "), ("\n\n", "\n"), ("\n \n", "\n ")] {
            while result.contains(asIs) {
                result = result.replacingOccurrences(of: asIs, with: toBe)
            }
        }
        
        return result.filter { $0.unicodeScalars.contains(where: \.properties.isEmojiPresentation) == false }
    }
}

private enum TextInputSheetValidatorKey: DependencyKey {
    static var liveValue: TextValidator = { oldValue, newValue in
        var result = newValue
        
        for (asIs, toBe) in [("   ", "  "), ("\n\n", "\n"), ("\n \n", "\n "), ("\n  \n", "\n  ")] {
            while result.contains(asIs) {
                result = result.replacingOccurrences(of: asIs, with: toBe)
            }
        }
        
        return result.filter { $0.unicodeScalars.contains(where: \.properties.isEmojiPresentation) == false }
    }
}

extension DependencyValues {
    var commentInputValidator: TextValidator {
        get { self[CommentInputValidatorKey.self] }
        set { self[CommentInputValidatorKey.self] = newValue }
    }
    
    var textInputSheetValidator: TextValidator {
        get { self[TextInputSheetValidatorKey.self] }
        set { self[TextInputSheetValidatorKey.self] = newValue }
    }
}
