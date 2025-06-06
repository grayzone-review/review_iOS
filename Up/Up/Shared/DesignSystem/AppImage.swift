//
//  AppImage.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import SwiftUI

enum AppImage: String {
    case intersetLine = "im_interset_line"
    case mymapLine = "im_mymap_line"
    case myplaceLine = "im_myplace_line"
    
    var image: Image {
        Image(rawValue)
            .resizable()
    }
}
