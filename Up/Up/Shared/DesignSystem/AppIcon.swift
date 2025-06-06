//
//  AppIcon.swift
//  Up
//
//  Created by Jun Young Lee on 6/2/25.
//

import SwiftUI

enum AppIcon: String {
    case arrowLeft = "ic_arrow_left_l_line"
    case arrowRight = "ic_arrow_right_l_line"
    case chatFill = "ic_chat_fill"
    case chatLine = "ic_chat_line"
    case clockLine = "ic_clock_line"
    case closeFill = "ic_close_fill"
    case closeLine = "ic_close_line"
    case followLine = "ic_follow_line"
    case followingFill = "ic_following_fill"
    case heartFill = "ic_heart_fill"
    case heartLine = "ic_heart_line"
    case infoFill = "ic_info_fill"
    case lockFill = "ic_lock_fill"
    case mapPinFill = "ic_map_pin_fill"
    case penFill = "ic_pen_fill"
    case reviewFill = "ic_review_fill"
    case searchLine = "ic_search_line"
    case sendFill = "ic_send_fill"
    case starFill = "ic_star_fill"
    case starHalfFill = "ic_star_half_fill"
    case unlockLine = "ic_unlock_line"
    
    var image: Image {
        Image(rawValue)
            .resizable()
    }
}
