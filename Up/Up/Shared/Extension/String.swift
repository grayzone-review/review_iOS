//
//  String.swift
//  Up
//
//  Created by Jun Young Lee on 6/1/25.
//

import Foundation

extension String {
    var withZeroWidthSpaces: String {
        self.map(String.init).joined(separator: "\u{200B}")
    }
}
