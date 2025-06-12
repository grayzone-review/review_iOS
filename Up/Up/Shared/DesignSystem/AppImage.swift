//
//  AppImage.swift
//  Up
//
//  Created by Jun Young Lee on 6/6/25.
//

import SwiftUI

enum AppImage: String {
    case intersetLine = "im_interset_line"
    case intersetFill = "im_interset_fill"
    case mymapLine = "im_mymap_line"
    case mymapFill = "im_mymap_fill"
    case myplaceLine = "im_myplace_line"
    case myplaceFill = "im_myplace_fill"
    
    var image: Image {
        Image(rawValue)
            .resizable()
    }
}
