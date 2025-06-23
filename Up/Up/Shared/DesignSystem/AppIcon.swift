//
//  AppIcon.swift
//  Up
//
//  Created by Jun Young Lee on 6/2/25.
//

import SwiftUI

enum AppIcon: String {
    case appleFill = "ic_apple_fill"
    case arrowDown = "ic_arrow_down_l_line"
    case arrowLeft = "ic_arrow_left_l_line"
    case arrowRight = "ic_arrow_right_l_line"
    case arrowUp = "ic_arrow_up_l_line"
    case chatFill = "ic_chat_fill"
    case chatLine = "ic_chat_line"
    case chatSecondFill = "ic_chat2_fill"
    case chatSecondLine = "ic_chat2_line"
    case checkCircleFill = "ic_check_circle_fill"
    case checkLine = "ic_check_line"
    case clockLine = "ic_clock_line"
    case closeCircleFill = "ic_close_circle_fill"
    case closeCircleLine = "ic_close_circle_line"
    case closeLine = "ic_close_line"
    case followLine = "ic_follow_line"
    case followingFill = "ic_following_fill"
    case heartFill = "ic_heart_fill"
    case heartLine = "ic_heart_line"
    case homeFill = "ic_home_fill"
    case homeLine = "ic_home_line"
    case infoFill = "ic_info_fill"
    case kakaoFill = "ic_kakao_fill"
    case lockFill = "ic_lock_fill"
    case mapFill = "ic_map_fill"
    case mapPinFill = "ic_map_pin_fill"
    case officeFill = "ic_office_fill"
    case penFill = "ic_pen_fill"
    case reviewFill = "ic_review_fill"
    case searchLine = "ic_search_line"
    case sendFill = "ic_send_fill"
    case starFill = "ic_star_fill"
    case starHalfFill = "ic_star_half_fill"
    case unlockLine = "ic_unlock_line"
    case userFill = "ic_user_fill"
    case userLine = "ic_user_line"
    
    var image: Image {
        Image(rawValue)
            .resizable()
    }
    
    // 사이즈와 색상이 지정된 경우 사용
    func image(width: CGFloat, height: CGFloat, appColor: AppColor) -> some View {
        image
            .frame(width: width, height: height)
            .foregroundStyle(appColor.color)
    }
}
