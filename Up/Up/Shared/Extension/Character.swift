//
//  Character.swift
//  Up
//
//  Created by Jun Young Lee on 6/20/25.
//

extension Character {
    var isEmoji: Bool {
        return self.unicodeScalars.contains { $0.properties.isEmojiPresentation || $0.properties.isEmoji }
    }
}
