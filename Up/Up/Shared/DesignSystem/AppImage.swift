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
    case mapPin = "im_map_pin"
    case banner = "im_banner"
    case onboarding1 = "im_onboarding_1"
    case onboarding2 = "im_onboarding_2"
    case onboarding3 = "im_onboarding_3"
    case logo = "im_logo"
    
    var image: Image {
        Image(rawValue)
            .resizable()
    }
}
